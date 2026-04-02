# Azure DocumentDB (with MongoDB compatibility) with Terraform

Deploy Azure DocumentDB (with MongoDB compatibility) with Customer Managed Keys, High Availability, and Geo-Replication.

## Features

- **MongoDB-compatible vCore 8.0** with M30 compute tier
- **High Availability** with Zone Redundant deployment
- **Customer Managed Keys** via Azure Key Vault
- **Private Endpoint** connectivity
- **Geo-Replication** to secondary region
- **Network Isolation** with VNet and Private DNS

## Deployment

> Note: The Azure service is now branded as Azure DocumentDB. Some Terraform resources and outputs may still use legacy Cosmos DB Mongo vCore naming.

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
