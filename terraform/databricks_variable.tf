variable "dbk_node_type" {
  type        = string
  description = "(Required) Node type of Databricks cluster."
}

variable "dbk_spark_version" {
  type        = string
  description = "(Required) Databricks runtime version."
}