# sandstock-infra


This repository manages all Azure resources of sandstock, a sandbox azure project to gather and maintain all good practices in a Azure solution.


## Manual action

### Data Factory

#### Approve Private Managed Endpoints

1. In Databricks "Networking" section, approve ADF endpoint.
2. In Azure SQL "Networking" section, approve ADF endpoint.
3. In Azure Storage "Networking" section, approve ADF endpoint.

All components of Azure Data Factory are managed within terraform, except Pipelines and Triggers.
See https://github.com/VictorMeyer77/sandstock-adf for more details.

### Azure Automation

#### Add Entra ID role on Azure Automation Identity

1. Copy the Azure Automation object_id in "Identity" section.
2. In Entra ID "Roles and administrators", add the "Application Administrator" role for the Azure Automation SystemAssigned Identity.
3. Launch automation source control synchronization (cf: https://github.com/VictorMeyer77/sandstock-runbook)

### Web App

Few minutes after the end of the `terraform apply`, release Web App with https://github.com/VictorMeyer77/sandstock.

## TODO

### Blob Storage

- [ ] Prevent destroy

### Azure SQL

- [x] Add init script to create user with permissions
- [ ] Prevent destroy
- [ ] Distinct user for Web app and ADF

### Datafactory

- [x] Configure triggers
- [x] Create GitHub action to turn on/off triggers

### Databricks

- [ ] Distinct dev cluster and run cluster
- [ ] Activate Unity Catalog
- [x] Configure databricks repository (cf: https://github.com/VictorMeyer77/sandstock-databricks)

### Identity

- [x] Create a group for web app accessing
- [x] Add an Azure Automation to automatically rotate Databricks Application Password
- [ ] Scale up to premium account and enable [SSPR](https://learn.microsoft.com/en-us/entra/identity/authentication/tutorial-enable-sspr)
- [ ] Process authentication logs

### Network

### Key Vault

- [ ] Prevent destroy
- [ ] Add in virtual network and open managed private endpoint (not available yet with Azure Automation)

### Web App

- [x] WebApp -> Azure SQL: store password and access password with key vault
- [ ] Configure deployment slot
- [ ] Use https

### Administration

- [ ] Add start/shut down auto for web app, azure sql, databricks cluster...
- [x] Logs monitoring
- [ ] Configure CI-CD to deploy infra with GitHub action
