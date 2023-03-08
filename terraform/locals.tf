locals {
  name = "${var.application}-${var.environment}"

  template_vars = {
    application = var.application
    environment = var.environment
  }

  tags = {
    "Name"                = local.name
    "ApplicationName"     = var.application
    "Environment"         = var.environment
    "ApplicationID"       = "sanitized"
    "Component"           = "sanitized"
    "CostCenter"          = "sanitized"
    "ProjectCode"         = "sanitized"
    "BusinessCriticality" = "sanitized"
    "ManagedBy"           = "terraform"
  }
}