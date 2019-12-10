variable "gcp_project" {}
variable "gcp_region" {}
variable "gcp_zone" {}
variable "machine_type" {}
variable "ssh_user" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}
variable "godaddy_api_key" {}
variable "domain" {}
variable "dns_managed_zone_name" {}
variable "contact_email" {}
variable "restore_backup" {
  default = false
}

variable "mysql_root_password" {}

variable "DB_HOST" {}

variable "DB_NAME" {}
variable "DB_PASS" {}
variable "DB_PORT" {}
variable "DB_USER" {}
variable "NODE_ENV" {}
variable "SESSION_SECRET" {}