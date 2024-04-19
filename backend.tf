
terraform {
  backend "s3" {
    bucket         = "statefile-bucket001"
    key            = "terraform.tfstate"
    region         = "us-east-1"  # Replace with your desired region
    encrypt        = true
    
  }
}
