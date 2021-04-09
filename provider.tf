provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tfstateepsilontraining3"
    key    = "epsilon/joseth/asg/tfstate"
    region = "us-east-1"
  }
}