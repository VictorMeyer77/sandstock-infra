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