terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" 
      version = ">= 4.34.0"     
    }
    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.20"
    }
    restapi = {
      source = "Mastercard/restapi"
      version = "1.18.0"
    }
  }
}

