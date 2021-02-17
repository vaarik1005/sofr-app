# General Variables

variable "this_profile" {
  description = "The aws profile to use"
  type        = string
  default     = "awc-n-ny-apps"
}

variable "region" {
  description = "The AWS region to use"
  type        = string
  default     = "us-east-2"
}

variable "ApplicationName" {
  description = "Application Name - Environment"
  default     = "ofr-dev"
  type        = string
}

variable "HostedZoneId" {
  description = "The hosted zone ID"
  default     = "Z0267734XYWRXH6VGB3Y"
  type        = string
}

variable "IntCertArn" {
  description = "Internal ALB Certificate ARN"
  default     = "arn:aws:acm:us-east-2:415754506132:certificate/8dc0fe14-e5e4-419f-a8f7-c163fa5413be"
  type        = string
}

# VPC Variables

variable "vpc_1_name" {
  description = "The name of VPC 1"
  default = "awc-n-ny-apps-vpc-apps"
  type        = string
}

variable "vpc_1_private_subnet_1" {
  description = "The name of private subnet 1"
  default = "awc-n-ny-apps-net-private-1"
  type        = string
}

variable "vpc_1_private_subnet_2" {
  description = "The name os private subnet 2"
  default = "awc-n-ny-apps-net-private-2"
  type        = string
}

variable "vpc_1_public_subnet_1" {
  description = "The name of public subnet 1"
  default = "awc-n-ny-apps-net-public-1"
  type        = string
}

variable "vpc_1_public_subnet_2" {
  description = "The name os public subnet 2"
  default = "awc-n-ny-apps-net-public-2"
  type        = string
}

# S3 Variables

variable "ArtifactsBucketName" {
  description = "Lambda Artifacts S3 Bucket Name"
  default     = "frbny-sofr-dev-artifacts"
  type        = string
}

variable "DeploymentBucketName" {
  description = "Deployment S3 Bucket Name"
  default     = "frbny-deployment-sofr-dev-artifacts"
  type        = string
}

variable "SOFRInputFilesBucketName" {
  description = "Deployment S3 Bucket Name"
  default     = "frbny-sofr-dev-input-repo-files"
  type        = string
}

variable "SOFROutputFilesBucketName" {
  description = "Deployment S3 Bucket Name"
  default     = "frbny-sofr-dev-output-repo-files"
  type        = string
}

# IAM Variables 

variable "BoundaryPolicyName" {
  description = "Service Management Role Name"
  default     = "devops-iamp-frs-permissions-boundary"
  type        = string
}

# KMS Variables

variable "kms_key_for_s3_name" {
  description = "The alias of the S3 KMS Key"
  default = "sofr-secrets-kms-key_tf"
  type        = string
}

variable "kms_key_for_lambda_name" {
  description = "The alias of the lambda KMS Key"
  default = "sofr-lambda-kms-key_tf"
  type        = string
}

# Lambda Variables

variable "DeploymentMode" {
  description = "Stack Deployment Mode"
  default     = "main"
  type        = string

  #validation {
  #  condition     = var.DeploymentMode == "main" || var.DeploymentMode == "promote" # Terraform version 0.13 only
  #  error_message = "The DeploymentMode value must be main or promote"
  #}
}

variable "ArchivalFolderName" {
  description = "Repo Files Archival Folder Name"
  default     = "processed"
  type        = string
}

variable "LambdaNewSubmissionsLoc" {
  description = "New Submission Listing Function file name"
  default     = "ofr-fp-aws-poc-1.0.0.jar"
  type        = string
}

variable "LambdaProcessorLoc" {
  description = "SOFR File Processor Function file name"
  default     = "ofr-fp-aws-poc-1.0.0.jar"
  type        = string
}

# Tagging variables

variable "Tag2ndLevelSupportValue" {
  description = "Value of the Tag: 2nd Level Support"
  default     = "B1-TECS-Application-Delivery-Services"
}

variable "TagappCiNameValue" {
  description = "Value of the Tag: Application System CI Name"
  default     = "SOFR-DEV"
}

variable "TagCIEnvironmentValue" {
  description = "Value of the Tag: CI Environment"
  default     = "dev"
  type        = string
}

variable "TagcreatedDateValue" {
  description = "Value of the Tag: Created Date"
  default     = "02/09/2021"
  type        = string
}

variable "TagdataClassificationValue" {
  description = "Value of the Tag: Information Classification"
  default     = "NONCONFIDENTIAL"
  type        = string
}

variable "TagDeptCodeValue" {
  description = "Value of the Tag: Department Code"
  default     = 2901
  type        = number
}

variable "TaglobValue" {
  description = "Value of the Tag: Line of Business"
  default     = "GCBSOFR000"
  type        = string
}

variable "TagmanagedByValue" {
  description = "Value of the Tag: Accounting Code"
  default     = "Reserve Banks"
  type        = string
}

variable "TagtaggingVersionValue" {
  description = "Value of the Tag: Tagging Version"
  default     = 1
  type        = number
}
#variable "NewSubsLambda" {
#type = string
  #}
