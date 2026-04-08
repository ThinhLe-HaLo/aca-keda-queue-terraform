terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.56.0"
    }
      random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
    
    }
  subscription_id = "562667b3-e621-41af-a17b-bf1ad368bde2"
}