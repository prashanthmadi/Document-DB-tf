output "mongo_cluster_id" {
  description = "The ID of the MongoDB cluster"
  value       = azurerm_mongo_cluster.mongo.id
}

output "mongo_cluster_name" {
  description = "The name of the MongoDB cluster"
  value       = azurerm_mongo_cluster.mongo.name
}

output "mongo_cluster_connection_strings" {
  description = "The connection strings for the MongoDB cluster"
  value       = azurerm_mongo_cluster.mongo.connection_strings
  sensitive   = true
}

output "mongo_admin_username" {
  description = "The administrator username for MongoDB"
  value       = azurerm_mongo_cluster.mongo.administrator_username
}

output "mongo_admin_password" {
  description = "The administrator password for MongoDB"
  value       = random_password.mongo_password.result
  sensitive   = true
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "private_endpoint_ip" {
  description = "The private IP address of the MongoDB cluster"
  value       = azurerm_private_endpoint.mongo_pe.private_service_connection[0].private_ip_address
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "cmk_key_id" {
  description = "The ID of the Customer Managed Key"
  value       = azurerm_key_vault_key.cmk.id
}

output "mongo_replica_id" {
  description = "The ID of the MongoDB cluster geo-replica"
  value       = azurerm_mongo_cluster.mongo_replica.id
}

output "mongo_replica_name" {
  description = "The name of the MongoDB cluster geo-replica"
  value       = azurerm_mongo_cluster.mongo_replica.name
}

output "mongo_replica_location" {
  description = "The location of the MongoDB cluster geo-replica"
  value       = azurerm_mongo_cluster.mongo_replica.location
}
