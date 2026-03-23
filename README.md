# Azure Cosmos DB for MongoDB vCore with Terraform

Deploy Azure Cosmos DB for MongoDB (vCore) with Customer Managed Keys, High Availability, and Geo-Replication.

## Features

- **MongoDB vCore 8.0** with M30 compute tier
- **High Availability** with Zone Redundant deployment
- **Customer Managed Keys** via Azure Key Vault
- **Private Endpoint** connectivity
- **Geo-Replication** to secondary region
- **Network Isolation** with VNet and Private DNS

## Deployment

```bash
# Login to Azure
az login
az account set --subscription <subscription-id>

# Deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Configuration

Default regions: Central US (primary) and East US 2 (replica). Customize in [variables.tf](variables.tf).

## Get Connection Info

```bash
terraform output mongo_cluster_connection_strings
terraform output mongo_admin_password
```

## Clean Up

```bash
terraform destroy
```

## License

MIT
