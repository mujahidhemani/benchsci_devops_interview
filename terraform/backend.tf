terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "mhemani"

    workspaces {
      prefix = "benchsci-webserver-"
    }
  }
}