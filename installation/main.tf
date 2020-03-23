# Installation 
module "ptfe-installation-bin" {
  source = "github.com/andrewpopa/terraform-aws-s3"
  bucket = "ptfe-installation-bin"
  force_destroy = true
  region        = "eu-central-1"
  versioning    = true
  tags = {
    Name = "ptfe-installation-bin"
  }
}