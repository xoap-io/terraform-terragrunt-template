locals {
  accounts             = {
    "security" : {
      email     = ""
      name      = "security"
      parent_id = "security"
    }

  }
  organisational_units = {
    core     = "core"
    security = "security"
    stages   = "stages"
  }
  role_name = "OrganizationAccountAccessRole"
}