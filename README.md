# Azure Cosmos DB for MongoDB vCore with Terraform

Deploy Azure Cosmos DB for MongoDB (vCore) with Customer Managed Keys, High Availability, and Geo-Replication.

## ⚠️ Known Limitation

**Azure Cosmos DB for MongoDB vCore does not support replicas in different resource groups.**

When attempting to deploy a replica in a different resource group, you'll get:
```
Error: bad_request: Cannot create replica in a different resource group from the source cluster.
```

**This repo demonstrates the limitation.** To deploy successfully, modify line 167 in `main.tf`:
```hcl
# Change from:
resource_group_name = azurerm_resource_group.rg_replica.name
# To:
resource_group_name = azurerm_resource_group.rg.name
```

## Features

- **MongoDB vCore 8.0** with M30 compute tier
- **High Availability** with Zone Redundant deployment
- **Customer Managed Keys** via Azure Key Vault
- **Private Endpoint** connectivity
- **Geo-Replication** to secondary region
- **Network Isolation** with VNet and Private DNS

## Quick Start

```bash
terraform init
terraform apply
```

## Configuration

Customize values in `terraform.tfvars` or use variables:
```bash
terraform apply -var="location=East US" -var="replica_location=West US"
```

See [variables.tf](variables.tf) for all options.

## Get Connection Info

```bash
terraform output mongo_cluster_connection_strings
terraform output mongo_admin_password
```

## Security Notes

- MongoDB cluster has public access disabled
- Uses CMK encryption with Key Vault
- Admin password auto-generated
- State files contain secrets (excluded via .gitignore)

## Clean Up

```bash
terraform destroy
```

## License

MIT
