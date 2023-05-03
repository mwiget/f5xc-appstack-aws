provider "volterra" {
  api_p12_file = var.f5xc_api_p12_file
  url          = var.f5xc_api_url
  timeout      = "30s"
}

provider "aws" {
  region = "eu-north-1"
  alias  = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region = "eu-south-1"
  alias  = "eu-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
