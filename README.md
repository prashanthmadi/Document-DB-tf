# Azure DocumentDB (with MongoDB compatibility) with Terraform

Deploy Azure DocumentDB (with MongoDB compatibility) with Customer Managed Keys, High Availability, and Geo-Replication.

## Features

- **MongoDB-compatible vCore 8.0** with M30 compute tier
- **High Availability** with Zone Redundant deployment
- **Customer Managed Keys** via Azure Key Vault
- **Private Endpoint** connectivity
- **Geo-Replication** to secondary region
- **Network Isolation** with VNet and Private DNS

## Architecture

```
                          Azure Subscription
 ┌──────────────────────────────────────────────────────────────────────────┐
 │                                                                          │
 │   ┌─ Region: Central US ──────────────┐    ┌─ Region: East US 2 ───────┐ │
 │   │  RG: rg-documentdb-centralus      │    │  RG: rg-documentdb-replica│ │
 │   │                                   │    │                           │ │
 │   │  ┌──────────────────────────────┐ │    │ ┌───────────────────────┐ │ │
 │   │  │ vnet-documentdb              │ │    │ │ vnet-documentdb-replica│ │
 │   │  │ 10.0.0.0/25                  │ │    │ │ 10.1.0.0/25           │ │ │
 │   │  │                              │ │    │ │                       │ │ │
 │   │  │  snet-privateendpoint        │ │    │ │ snet-privateendpoint  │ │ │
 │   │  │  10.0.0.0/27                 │ │    │ │ 10.1.0.0/27           │ │ │
 │   │  │  ┌────────────────────────┐  │ │    │ │ ┌──────────────────┐  │ │ │
 │   │  │  │ PE: pe-mongo-cluster   │  │ │    │ │ │ PE: pe-mongo-    │  │ │ │
 │   │  │  │  10.0.0.4              │  │ │    │ │ │      replica     │  │ │ │
 │   │  │  └───────────┬────────────┘  │ │    │ │ │  10.1.0.4        │  │ │ │
 │   │  │              │               │ │    │ │ └─────────┬────────┘  │ │ │
 │   │  └──────────────┼───────────────┘ │    │ └───────────┼───────────┘ │ │
 │   │                 │                 │◄──►│             │             │ │
 │   │                 │      VNet peering (primary ⇄ replica)            │ │
 │   │                 ▼                 │    │             ▼             │ │
 │   │  ┌──────────────────────────────┐ │    │ ┌───────────────────────┐ │ │
 │   │  │ Mongo Cluster (PRIMARY)      │ │    │ │ Mongo Cluster (REPLICA│ │
 │   │  │ mongo-cluster-xxxx           │◄┼────┼─┤ create_mode=GeoReplica│ │ │
 │   │  │ M30, HA: ZoneRedundantPref'd │ │    │ │ source = primary      │ │ │
 │   │  │ Public access: Disabled      │ │    │ │                       │ │ │
 │   │  │ CMK encryption (UAMI)        │ │    │ │                       │ │ │
 │   │  └──────────────┬───────────────┘ │    │ └───────────────────────┘ │ │
 │   │                 │                 │    │                           │ │
 │   │  ┌──────────────▼───────────────┐ │    │                           │ │
 │   │  │ Key Vault (kv-mongo-xxxx)    │ │    │                           │ │
 │   │  │  └─ CMK key (RSA 2048)       │ │    │                           │ │
 │   │  │ User-Assigned MI: id-mongodb │ │    │                           │ │
 │   │  └──────────────────────────────┘ │    │                           │ │
 │   └───────────────────────────────────┘    └───────────────────────────┘ │
 │                                                                          │
 │   ┌────────────────────────────────────────────────────────────────────┐ │
 │   │ Private DNS Zone: privatelink.mongocluster.cosmos.azure.com        │ │
 │   │   linked to:  vnet-documentdb   AND   vnet-documentdb-replica      │ │
 │   └────────────────────────────────────────────────────────────────────┘ │
 └──────────────────────────────────────────────────────────────────────────┘

App connection (failover-aware):
  mongodb+srv://...@<cluster>.global.mongocluster.cosmos.azure.com/...
  └─ "global" CNAME flips to current writer on failover; private DNS resolves
     to whichever PE is local (or reachable via peering).
```

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
