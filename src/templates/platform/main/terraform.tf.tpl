
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-valiant-tf-backend"
    storage_account_name = "savalianttfbackend"
    container_name       = "tfstate"
    key                  = "terraform.tfstate" # refers to the file name
  }
}


terraform {
  required_version = ">= 1.3.0"

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.57.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.39.0"
    }
  }
}
