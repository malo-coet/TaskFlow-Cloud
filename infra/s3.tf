resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "taskflow-frontend-mcoet"
  tags = {
    Name        = "Frontend Repo"
    Environment = "Dev"
  }
}
