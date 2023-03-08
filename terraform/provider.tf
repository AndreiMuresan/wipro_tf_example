provider "aws" {
  profile = "default"
  region  = var.default_region
}

# create secondary provider because the CUR report definition resource can only be created in sanitized  
# can be removed if the Cost and Usage Report is already created
provider "aws" {
  region = "sanitized"
  alias  = "sanitized"
}