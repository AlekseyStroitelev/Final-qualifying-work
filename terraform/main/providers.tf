terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.5"
  
  backend "s3" {
    bucket     = "alexey1406"
    key        = "terraform.tfstate"
    shared_credentials_files = [ "~/.yc/credentials" ]
    profile = "default"
    region = "ru-central1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file("./service_account_key_file.json")
}
