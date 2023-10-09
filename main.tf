terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
  }
  #backend "remote" {
  #  hostname = "app.terraform.io"
  #  organization = "ExamPro"

  #  workspaces {
  #    name = "terra-house-1"
  #  }
  #}
  cloud {
    organization = "Ajmaltech"
    workspaces {
      name = "terra-house-1"
    }
  }

}

provider "terratowns" {
  endpoint = var.terratowns_endpoint
  user_uuid = var.teacherseat_user_uuid
  token = var.terratowns_access_token
}

module "home_arcanum_hosting" {
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path = var.arcanum.public_path
  content_version = var.arcanum.content_version
}

resource "terratowns_home" "home" {
  name = "Welcome to Game Hub"
  description = <<DESCRIPTION
Here, you can showcase some of your favorite games or
provide information about popular games. Include images,
descriptions, and links to more details.    
DESCRIPTION
  domain_name = module.home_arcanum_hosting.domain_name
  town = "missingo"
  content_version = var.arcanum.content_version
}

module "home_payday_hosting" {
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path = var.payday.public_path
  content_version = var.payday.content_version
}

resource "terratowns_home" "home_payday" {
  name = "Tuna and Sweetcorn Salad"
  description = <<DESCRIPTION
Tuna and Sweetcorn Salad is a delightful and nutritious dish
that brings together the fresh flavors of the ocean and the
sweetness of tender corn kernels in a harmonious blend. 
DESCRIPTION
  domain_name = module.home_payday_hosting.domain_name
  town = "cooker-cove"
  content_version = var.payday.content_version
}
