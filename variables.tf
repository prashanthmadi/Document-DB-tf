# You can customize these variables as needed

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-documentdb-centralus"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Central US"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network (/25 = 128 addresses)"
  type        = list(string)
  default     = ["10.0.0.0/25"]
}

variable "pe_subnet_prefix" {
  description = "Address prefix for private endpoint subnet (/27 = 32 addresses, 27 usable)"
  type        = list(string)
  default     = ["10.0.0.0/27"]
}

variable "mongo_compute_tier" {
  description = "Compute tier for MongoDB cluster"
  type        = string
  default     = "M30"
}

variable "mongo_shard_count" {
  description = "Number of shards for MongoDB cluster"
  type        = number
  default     = 1
}

variable "mongo_storage_size_gb" {
  description = "Storage size in GB for MongoDB cluster"
  type        = number
  default     = 128
}

variable "mongo_version" {
  description = "MongoDB version"
  type        = string
  default     = "8.0"
}

variable "mongo_admin_username" {
  description = "Administrator username for MongoDB"
  type        = string
  default     = "mongoadmin"
}

variable "high_availability_mode" {
  description = "High availability mode (Disabled or ZoneRedundantPreferred)"
  type        = string
  default     = "ZoneRedundantPreferred"
}

variable "replica_location" {
  description = "Azure region for the geo-replica"
  type        = string
  default     = "East US 2"
}

variable "replica_resource_group_name" {
  description = "Name of the resource group for the replica"
  type        = string
  default     = "rg-documentdb-replica-eastus2"
}

variable "replica_vnet_address_space" {
  description = "Address space for the replica region virtual network (/25 = 128 addresses)"
  type        = list(string)
  default     = ["10.1.0.0/25"]
}

variable "replica_pe_subnet_prefix" {
  description = "Address prefix for the replica region private endpoint subnet (/27 = 32 addresses, 27 usable)"
  type        = list(string)
  default     = ["10.1.0.0/27"]
}
