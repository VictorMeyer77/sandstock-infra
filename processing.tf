# Databricks


data "databricks_node_type" "node_type" {
  local_disk = true
  depends_on = [
    azurerm_databricks_workspace.dbk
  ]
}

data "databricks_spark_version" "spark_version" {
  long_term_support = true
  depends_on = [
    azurerm_databricks_workspace.dbk
  ]
}

resource "azurerm_databricks_workspace" "dbk" {
  name                        = "${var.environment}-${var.project}-dbk"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  managed_resource_group_name = "${var.environment}-${var.project}-dbk-mng"
  sku                         = "premium"

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.vnet.id
    private_subnet_name                                  = azurerm_subnet.dbk_pri_subnet.name
    public_subnet_name                                   = azurerm_subnet.dbk_pub_subnet.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.nsg_dbk_aso_pub.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.nsg_dbk_aso_pri.id
  }

  tags = var.tags

}

resource "databricks_secret_scope" "secret_scope" {
  name = "${var.environment}-${var.project}-dbk-kv"

  keyvault_metadata {
    resource_id = azurerm_key_vault.kv.id
    dns_name    = azurerm_key_vault.kv.vault_uri
  }
}

resource "databricks_cluster" "shared_autoscaling" {
  cluster_name            = "Shared Autoscaling"
  spark_version           = data.databricks_spark_version.spark_version.id
  node_type_id            = data.databricks_node_type.node_type.id
  autotermination_minutes = 20

  autoscale {
    min_workers = 1
    max_workers = 4
  }

  spark_conf = {
    "spark.databricks.io.cache.enabled" : true
    "spark.hadoop.fs.azure.account.auth.type.${azurerm_storage_account.storage.name}.dfs.core.windows.net"              = "OAuth"
    "spark.hadoop.fs.azure.account.oauth.provider.type.${azurerm_storage_account.storage.name}.dfs.core.windows.net"    = "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider"
    "spark.hadoop.fs.azure.account.oauth2.client.id.${azurerm_storage_account.storage.name}.dfs.core.windows.net"       = azuread_application.dbk_app.client_id
    "spark.hadoop.fs.azure.account.oauth2.client.secret.${azurerm_storage_account.storage.name}.dfs.core.windows.net"   = "{{secrets/${databricks_secret_scope.secret_scope.name}/${azurerm_key_vault_secret.dbk_app_client_secret.name}}}"
    "spark.hadoop.fs.azure.account.oauth2.client.endpoint.${azurerm_storage_account.storage.name}.dfs.core.windows.net" = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/token"
  }

  library {
    pypi {
      package = "black==25.1.0"
    }
  }

  depends_on = [
    azurerm_databricks_workspace.dbk
  ]

}

# Datafactory

resource "azurerm_data_factory" "adf" {
  name                            = "${var.environment}-${var.project}-adf"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }

  github_configuration {
    account_name       = var.adf_github_account
    branch_name        = "main"
    repository_name    = var.adf_github_repository
    root_folder        = "/"
    publishing_enabled = true
  }

  tags = var.tags
}

resource "azurerm_data_factory_integration_runtime_azure" "adf_runtime" {
  name                    = "${var.environment}-${var.project}-runtime"
  data_factory_id         = azurerm_data_factory.adf.id
  location                = azurerm_resource_group.rg.location
  compute_type            = "General"
  core_count              = 8
  virtual_network_enabled = true
  time_to_live_min        = 10
}

# Linked Services

resource "azurerm_data_factory_linked_service_azure_sql_database" "adf_sql" {
  name                     = "${var.environment}-${var.project}-adf-sql"
  data_factory_id          = azurerm_data_factory.adf.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name

  connection_string = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.erp_db.name};User ID=sql_admin;Encrypt=True;Connection Timeout=30;"

  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.adf_kv.name
    secret_name         = azurerm_key_vault_secret.db_usr_pwd.name
  }

}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "adf_sto" {
  name                     = "${var.environment}-${var.project}-adf-sto"
  data_factory_id          = azurerm_data_factory.adf.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name
  url                      = azurerm_storage_account.storage.primary_dfs_endpoint
  use_managed_identity     = true

  #depends_on = [
  #  azurerm_storage_account.storage
  #]
}

resource "azurerm_data_factory_linked_service_key_vault" "adf_kv" {
  name                     = "${var.environment}-${var.project}-adf-kv"
  data_factory_id          = azurerm_data_factory.adf.id
  key_vault_id             = azurerm_key_vault.kv.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name

  #depends_on = [
  #  azurerm_key_vault.kv
  #]
}

resource "azurerm_data_factory_linked_service_azure_databricks" "adf_dbk" {
  name                       = "${var.environment}-${var.project}-adf-dbk"
  data_factory_id            = azurerm_data_factory.adf.id
  adb_domain                 = "https://${azurerm_databricks_workspace.dbk.workspace_url}"
  msi_work_space_resource_id = azurerm_databricks_workspace.dbk.id
  existing_cluster_id        = databricks_cluster.shared_autoscaling.cluster_id

  depends_on = [
    databricks_cluster.shared_autoscaling
  ]
}

# Datasets

resource "azurerm_data_factory_custom_dataset" "erp_table" {
  name            = "${var.environment}_erp_table"
  data_factory_id = azurerm_data_factory.adf.id
  type            = "AzureSqlTable"
  linked_service {
    name = azurerm_data_factory_linked_service_azure_sql_database.adf_sql.name
  }
  folder = "ERP"

  parameters = {
    table_name = "table"
  }

  type_properties_json = <<JSON
{
    "table": {
        "value": "@dataset().table_name",
        "type": "Expression"
    }
}
JSON

}


resource "azurerm_data_factory_dataset_parquet" "sto_dataset" {
  name                = "${var.environment}_sto_dataset"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.adf_sto.name
  folder              = "Storage"
  compression_codec   = "snappy"

  azure_blob_fs_location {
    dynamic_file_system_enabled = true
    dynamic_path_enabled        = true
    dynamic_filename_enabled    = true
    file_system                 = "@dataset().container"
    path                        = "@dataset().folder_path"
    filename                    = "@dataset().file_name"
  }

  parameters = {
    container   = "container"
    folder_path = "folder/"
    file_name   = "file.parquet"
  }
}