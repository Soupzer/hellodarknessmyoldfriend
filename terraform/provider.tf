terraform {
  required_version = ">= 0.13"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
  backend "local" {
    path = "/tmp/terraform1.tfstate"
  }
}
provider "kubernetes" {
  host               = "https://192.168.59.101:8443"
  client_certificate = file("~/.minikube/profiles/minikube/client.crt")
  client_key         = file("~/.minikube/profiles/minikube/client.key")
  insecure           = true
}