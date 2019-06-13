terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "noorim"

    workspaces {
      name = "nfs"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}