resource "azurerm_data_factory_pipeline" "adf_pip_plh" {
  name            = "TRIGGER_PLACEHOLDER"
  data_factory_id = azurerm_data_factory.adf.id
  description     = "Dummy pipeline to release triggers"
  folder          = "."
}

resource "azurerm_data_factory_trigger_schedule" "erp_etl_trg" {
  name            = "erp-etl-trg"
  data_factory_id = azurerm_data_factory.adf.id
  pipeline_name   = azurerm_data_factory_pipeline.adf_pip_plh.name
  description     = "Daily Trigger (1 A.M) of ERP ETL pipeline"
  activated       = true
  time_zone       = "UTC"
  start_time      = formatdate("YYYY-MM-DD'T'01:00:00'Z'", timestamp())
  interval        = 1
  frequency       = "Day"
}
