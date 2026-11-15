terraform {
  required_providers {
    # Permite criar recursos na AWS.
    aws = {
      source = "hashicorp/aws"
    }

    # Permite empacotar o código da Lambda em um ZIP.
    archive = {
      source = "hashicorp/archive"
    }
  }
}

# Usa a região definida em variables.tf.
provider "aws" {
  region = var.aws_region
}