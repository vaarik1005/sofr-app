data "aws_caller_identity" "current" {}

data aws_kms_key "s3_kms_key" {
    key_id = "alias/${var.kms_key_for_s3_name}"
}

data aws_kms_key "lambda_kms_key" {
    key_id = "alias/${var.kms_key_for_lambda_name}"
}

data "aws_vpc" "vpc_1" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_1_name]
  }
}

data "aws_subnet" "SUBNET-PRIVATE-AZ1-VPC1-ID" {
  vpc_id = data.aws_vpc.vpc_1.id
  filter {
    name   = "tag:Name"
    values = [var.vpc_1_private_subnet_1]
  }
}

data "aws_subnet" "SUBNET-PRIVATE-AZ2-VPC1-ID" {
  vpc_id = data.aws_vpc.vpc_1.id
  filter {
    name   = "tag:Name"
    values = [var.vpc_1_private_subnet_2]
  }
}

data "aws_subnet" "SUBNET-PUBLIC-AZ1-VPC1-ID" {
  vpc_id = data.aws_vpc.vpc_1.id
  filter {
    name   = "tag:Name"
    values = [var.vpc_1_public_subnet_1]
  }
}

data "aws_subnet" "SUBNET-PUBLIC-AZ2-VPC1-ID" {
  vpc_id = data.aws_vpc.vpc_1.id
  filter {
    name   = "tag:Name"
    values = [var.vpc_1_public_subnet_2]
  }
}

data "aws_security_group" "SG-OUT-ONLY-VPC1-ID" {
  name = "devops-sg-out-only-vpc1"
}

data "aws_security_group" "devops-sg-interfed-https-vpc1" {
  name = "devops-sg-interfed-https-vpc1"
}

data "aws_security_group" "devops-sg-markets-https-vpc1" {
  name = "devops-sg-markets-https-vpc1"
}

data "aws_route53_zone" "internal" {
  zone_id = var.HostedZoneId
}
data "aws_lb_target_group_attachment" "NewSubsLambda" {
   name = "NewSubsLambda"
    }

data "aws_iam_policy_document" "devops-processor-lambda-policy-tf" {
  statement {
    sid = "AllowKMSUseforS3"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncryptTo",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:DescribeKey",
      "kms:GenerateDataKeyPairWithoutPlaintext",
      "kms:GenerateDataKeyPair",
      "kms:ReEncryptFrom"
    ]
    resources = [data.aws_kms_key.s3_kms_key.arn]
  }

  statement {
    sid = "AllowS3Read"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.ArtifactsBucketName}",
      "arn:aws:s3:::${var.SOFRInputFilesBucketName}/*",
      "arn:aws:s3:::${var.SOFROutputFilesBucketName}/*"
    ]
  }

  statement {
    sid = "AllowS3Write"
    actions = [
      "s3:*Object",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.SOFRInputFilesBucketName}/*",
      "arn:aws:s3:::${var.SOFROutputFilesBucketName}/*"
    ]
  }
}

data "aws_iam_policy_document" "devops-query-lambda-policy-tf" {
  statement {
    sid = "AllowS3KMSDecrypt"
    actions = [
      "kms:Decrypt"
    ]
    resources = [data.aws_kms_key.s3_kms_key.arn]
  }

  statement {
    sid = "AllowS3Read"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.ArtifactsBucketName}",
      "arn:aws:s3:::${var.SOFROutputFilesBucketName}/*"
    ]
  }
}
