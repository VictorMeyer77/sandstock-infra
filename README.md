# sandstock-infra


This repository manages all Azure resources of sandstock, a sandbox azure project to gather and maintain all good practices in a Azure solution.


## Manual action

### Approve Private Managed Endpoints

1. In databricks "Networking" section, approve ADF endpoint.
2. In Azure SQL "Networking" section, approve ADF endpoint.
3. In Azure Storage "Networking" section, approve ADF endpoint.

## TODO

### Blob Storage

- [ ] Prevent destroy

### Azure SQL

- [ ] Add init script to create user with permissions
- [ ] Prevent destroy

### Datafactory

- [ ] configure triggers

### Databricks

- [ ] distinct dev cluster and prod cluster

### Identity

- [ ] Create a group for web app accessing
- [ ] Databricks app add password rotation

### Network

### Key Vault

- [ ] Add an Azure Automation to automatically rotate Databricks Application Password
- [ ] Prevent destroy

### Web App

- [ ] WebApp -> Azure SQL: store password and access password with key vault
- [ ] Configure development slot

### Administration

- [ ] Add start/shut down auto for web app, azure sql, databricks cluster...
- [ ] Logs monitoring
