provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true # Añade esta línea
  endpoints {
    s3          = "http://localhost:4566"
    ec2         = "http://localhost:4566"
    iam         = "http://localhost:4566"
    elbv2       = "http://localhost:4566" # Añadido para el Balanceador y Target Group
    autoscaling = "http://localhost:4566" # Añadido para el Auto Scaling Group
  }
}
