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