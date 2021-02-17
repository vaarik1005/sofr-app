provider "aws" {
 
  #app_acct_id   = "415754506132"
  region  = "us-east-2"
  profile = "awc-n-ny-apps"
  
  assume_role {
    role_arn = "arn:aws:iam::415754506132:role/devops-sts-jenkins-deploy"
  }

  }