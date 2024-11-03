terraform {
  backend "s3" {
    bucket = "bitclouded-tf-state"
    key    = "techchallenge"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  alias = "acm"
  region = "us-east-1"
}

module "static-site" {
  source  = "SPHTech-Platform/s3-cloudfront-static-site/aws"
  version = "0.3.3"

  providers = {
    aws.us-east-1 = aws.acm
  }

  create_certificate = true

  domains = {
    default_domain = {
      dns_zone_id         = "Z3BG4YQFIVKBOW"
      domain              = "techchallenge.bit-clouded.com"
      create_alias_record = true
      include_in_acm = true
      create_acm_record = true
    }
  }
}