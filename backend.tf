terraform {
backend "s3" {
region = "us-east-2"
bucket = "org-frb-ny-tg-sm-sofr-dev-app-terraform-backend"
key = "LockID"
dynamodb_table = "org-frb-ny-tg-sm-sofr-dev-app-terraform-backend-lock-table"
role_arn = "arn:aws:iam::415754506132:role/devops-sts-jenkins-deploy"
}
}
