terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  resource_provider_registrations = "none"
}

# Data source to get current client config
data "azurerm_client_config" "current" {}

# Random string for unique naming (must be defined early for use in resource names)
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Random password for MongoDB admin (must be defined early for use in cluster)
resource "random_password" "mongo_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Resource Group for Replica
resource "azurerm_resource_group" "rg_replica" {
  name     = var.replica_resource_group_name
  location = var.replica_location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-documentdb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
}

# Subnet for Private Endpoint
resource "azurerm_subnet" "pe_subnet" {
  name                 = "snet-privateendpoint"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.pe_subnet_prefix
}

# User Assigned Managed Identity for MongoDB Cluster
resource "azurerm_user_assigned_identity" "mongo_identity" {
  name                = "id-mongodb-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Key Vault for CMK
resource "azurerm_key_vault" "kv" {
  name                       = "kv-mongo-${random_string.suffix.result}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  public_network_access_enabled = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "List",
      "Delete",
      "Update",
      "GetRotationPolicy",
      "SetRotationPolicy"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.mongo_identity.principal_id

    key_permissions = [
      "Get",
      "WrapKey",
      "UnwrapKey"
    ]
  }
}


# Key Vault Key for CMK
resource "azurerm_key_vault_key" "cmk" {
  name         = "cmk-mongodb"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault.kv]
}

# MongoDB Cluster with HA
resource "azurerm_mongo_cluster" "mongo" {
  name                = "mongo-cluster-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_username = var.mongo_admin_username
  administrator_password = random_password.mongo_password.result

  compute_tier           = var.mongo_compute_tier
  shard_count            = var.mongo_shard_count
  storage_size_in_gb     = var.mongo_storage_size_gb
  high_availability_mode = var.high_availability_mode

  version = var.mongo_version

  public_network_access = "Disabled"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mongo_identity.id]
  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.cmk.versionless_id
    user_assigned_identity_id = azurerm_user_assigned_identity.mongo_identity.id
  }

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_key_vault_key.cmk
  ]
}

# MongoDB Cluster Replica (Geo-Replica for disaster recovery)
resource "azurerm_mongo_cluster" "mongo_replica" {
  name                = "mongo-replica-${random_string.suffix.result}"
  location            = var.replica_location
  resource_group_name = azurerm_resource_group.rg_replica.name

  source_server_id = azurerm_mongo_cluster.mongo.id
  source_location  = azurerm_mongo_cluster.mongo.location
  create_mode      = "GeoReplica"

  lifecycle {
    ignore_changes = [
      administrator_username,
      high_availability_mode,
      shard_count,
      storage_size_in_gb,
      compute_tier,
      version
    ]
  }

  depends_on = [azurerm_mongo_cluster.mongo]
}

# Private DNS Zone for MongoDB
resource "azurerm_private_dns_zone" "mongo_dns" {
  name                = "privatelink.mongocluster.cosmos.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "mongo_dns_link" {
  name                  = "mongo-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mongo_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Private Endpoint for MongoDB Cluster
resource "azurerm_private_endpoint" "mongo_pe" {
  name                = "pe-mongo-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "psc-mongo-cluster"
    private_connection_resource_id = azurerm_mongo_cluster.mongo.id
    is_manual_connection           = false
    subresource_names              = ["MongoCluster"]
  }

  private_dns_zone_group {
    name                 = "mongo-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.mongo_dns.id]
  }

  depends_on = [azurerm_mongo_cluster.mongo]
}
