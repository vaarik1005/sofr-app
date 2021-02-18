module "devops-processor-lambda-role" {
  source = "./module/terraform-aws-iam//modules/iam-assumable-role/"

  create_role                   = true
  role_requires_mfa             = false
  role_name                     = "devops-processor-lambda-role-tf"
  role_description              = "IAM service linked role for Processor Lambdas"
  role_permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.BoundaryPolicyName}"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  trusted_role_actions = [
    "sts:AssumeRole"
  ]

  number_of_custom_role_policy_arns = 2
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    module.devops-processor-lambda-policy.arn
  ]

  tags = {
    "2nd Level Support"          = var.Tag2ndLevelSupportValue
    "Application System CI Name" = var.TagappCiNameValue
    "CI Environment"             = var.TagCIEnvironmentValue
    "Created Date"               = var.TagcreatedDateValue
    "Information Classification" = var.TagdataClassificationValue
    "Department Code"            = var.TagDeptCodeValue
    "Line of Business"           = var.TaglobValue
    "Accounting Code"            = var.TagmanagedByValue
    "Tagging Version"            = var.TagtaggingVersionValue
  }
}

module "devops-processor-lambda-policy" {
  source = "./module/terraform-aws-iam//modules/iam-policy/"

  name        = "devops-processor-lambda-policy-tf"
  path        = "/"
  description = "Least Privileged Policy for Processor Lambda of SOFR application"
  policy      = data.aws_iam_policy_document.devops-processor-lambda-policy-tf.json
}

module "devops-query-lambdas-role" {
  source = "./module/terraform-aws-iam//modules/iam-assumable-role/"

  create_role                   = true
  role_requires_mfa             = false
  role_name                     = "devops-query-lambdas-role-tf"
  role_description              = "IAM service linked role for Query Lambdas"
  role_permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.BoundaryPolicyName}"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  trusted_role_actions = [
    "sts:AssumeRole"
  ]

  number_of_custom_role_policy_arns = 2
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    module.devops-query-lambda-policy.arn
  ]

  tags = {
    "2nd Level Support"          = var.Tag2ndLevelSupportValue
    "Application System CI Name" = var.TagappCiNameValue
    "CI Environment"             = var.TagCIEnvironmentValue
    "Created Date"               = var.TagcreatedDateValue
    "Information Classification" = var.TagdataClassificationValue
    "Department Code"            = var.TagDeptCodeValue
    "Line of Business"           = var.TaglobValue
    "Accounting Code"            = var.TagmanagedByValue
    "Tagging Version"            = var.TagtaggingVersionValue
  }
}

module "devops-query-lambda-policy" {
  source = "./module/terraform-aws-iam//modules/iam-policy/"

  name        = "devops-query-lambda-policy-tf"
  path        = "/"
  description = "Least Privileged Policy for Query Lambdas of SOFR application"
  policy      = data.aws_iam_policy_document.devops-query-lambda-policy-tf.json
}

module "ProcessorLambda" {
  source = "./module/terraform-aws-lambda/"

  function_name = "devops-SofrProcessor-tf"
  description   = "SOFR File Processor Lambda Function"
  handler       = "org.frb.ny.mods.ofr.lambda.handler.SofrFileHandler::handleRequest"
  runtime       = "java8"
  publish       = true
  memory_size   = 1024
  kms_key_arn   = data.aws_kms_key.lambda_kms_key.arn
  lambda_role   = module.devops-processor-lambda-role.this_iam_role_name_arn
  timeout       = 30

  store_on_s3 = true

  create_package = false
  s3_existing_package = {
    s3_bucket = var.DeploymentBucketName
    s3_key    = "functions/${var.LambdaProcessorLoc}"
  }

  vpc_security_group_ids = [data.aws_security_group.SG-OUT-ONLY-VPC1-ID.id]
  vpc_subnet_ids         = [data.aws_subnet.SUBNET-PRIVATE-AZ1-VPC1-ID.id, data.aws_subnet.SUBNET-PRIVATE-AZ2-VPC1-ID.id]

  environment_variables = {
    "deployment_mode"            = var.DeploymentMode
    "enrichment_file_name"       = "configuration/publish-enrichment-rules.json"
    "sofr_artifacts_bucket_name" = var.ArtifactsBucketName
    "sofr_intput_bucket_name"    = var.SOFRInputFilesBucketName
    "sofr_output_bucket_name"    = var.SOFROutputFilesBucketName
    "repo_archival_folder_name"  = var.ArchivalFolderName
  }

  tags = {
    "2nd Level Support"          = var.Tag2ndLevelSupportValue
    "Application System CI Name" = var.TagappCiNameValue
    "CI Environment"             = var.TagCIEnvironmentValue
    "Created Date"               = var.TagcreatedDateValue
    "Information Classification" = var.TagdataClassificationValue
    "Department Code"            = var.TagDeptCodeValue
    "Line of Business"           = var.TaglobValue
    "Accounting Code"            = var.TagmanagedByValue
    "Tagging Version"            = var.TagtaggingVersionValue
  }
}

resource "aws_cloudwatch_event_rule" "OFRFileArrivedRule" {
  name        = "devops-ofr-file-arrival-rule-tf"
  description = "Rule to send notification when a file arrives in the OFR input bucket"

  event_pattern = jsonencode(
    {
      source = [
        "aws.s3"
      ],
      detail-type = [
        "AWS API Call via CloudTrail"
      ],
      detail = {
        eventSource = ["s3.amazonaws.com"],
        eventName   = ["PutObject"],
        requestParameters = {
          bucketName = ["${var.SOFRInputFilesBucketName}"]
        }
      }
    }
  )
}

resource "aws_cloudwatch_event_target" "OFRFileArrivedRule" {
  rule      = aws_cloudwatch_event_rule.OFRFileArrivedRule.name
  target_id = "OFRFileArrived"
  arn       = module.ProcessorLambda.this_lambda_function_arn
}

resource "aws_lambda_permission" "EventsProcessorPerms" {
  action        = "lambda:InvokeFunction"
  function_name = module.ProcessorLambda.this_lambda_function_arn
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.OFRFileArrivedRule.arn
}

module "NewSubsLambda" {
  source = "./module/terraform-aws-lambda/"

  function_name = "devops_SofrNewSubmissions_tf"
  description   = "SOFR New Submissions Query Lambda Function"
  handler       = "org.frb.ny.mods.ofr.lambda.handler.SofrFileHandler::handleRequest"
  runtime       = "java8"
  publish       = true
  memory_size   = 1024
  kms_key_arn   = data.aws_kms_key.lambda_kms_key.arn
  lambda_role   = module.devops-query-lambdas-role.this_iam_role_name_arn
  timeout       = 30

  store_on_s3 = true

  create_package = false
  s3_existing_package = {
    s3_bucket = var.DeploymentBucketName
    s3_key    = "functions/${var.LambdaNewSubmissionsLoc}"
  }

  vpc_security_group_ids = [data.aws_security_group.SG-OUT-ONLY-VPC1-ID.id]
  vpc_subnet_ids         = [data.aws_subnet.SUBNET-PRIVATE-AZ1-VPC1-ID.id, data.aws_subnet.SUBNET-PRIVATE-AZ2-VPC1-ID.id]

  environment_variables = {
    "deployment_mode"            = var.DeploymentMode
    "enrichment_file_name"       = "configuration/publish-enrichment-rules.json"
    "sofr_artifacts_bucket_name" = var.ArtifactsBucketName
    "sofr_input_bucket_name"     = var.SOFRInputFilesBucketName
    "sofr_output_bucket_name"    = var.SOFROutputFilesBucketName
    "repo_archival_folder_name"  = var.ArchivalFolderName
  }

  tags = {
    "2nd Level Support"          = var.Tag2ndLevelSupportValue
    "Application System CI Name" = var.TagappCiNameValue
    "CI Environment"             = var.TagCIEnvironmentValue
    "Created Date"               = var.TagcreatedDateValue
    "Information Classification" = var.TagdataClassificationValue
    "Department Code"            = var.TagDeptCodeValue
    "Line of Business"           = var.TaglobValue
    "Accounting Code"            = var.TagmanagedByValue
    "Tagging Version"            = var.TagtaggingVersionValue
  }
}

module "SubIdLambda" {
  source = "./module/terraform-aws-lambda/"

  function_name = "devops-SofrSubmissionId-tf"
  description   = "SOFR New Submissions Query Lambda Function"
  handler       = "org.frb.ny.mods.ofr.lambda.handler.SofrFileHandler::handleRequest"
  runtime       = "java8"
  publish       = true
  memory_size   = 1024
  kms_key_arn   = data.aws_kms_key.lambda_kms_key.arn
  lambda_role   = module.devops-query-lambdas-role.this_iam_role_name_arn
  timeout       = 30

  store_on_s3 = true

  create_package = false
  s3_existing_package = {
    s3_bucket = var.DeploymentBucketName
    s3_key    = "functions/${var.LambdaNewSubmissionsLoc}"
  }

  vpc_security_group_ids = [data.aws_security_group.SG-OUT-ONLY-VPC1-ID.id]
  vpc_subnet_ids         = [data.aws_subnet.SUBNET-PRIVATE-AZ1-VPC1-ID.id, data.aws_subnet.SUBNET-PRIVATE-AZ2-VPC1-ID.id]

  environment_variables = {
    "deployment_mode"            = var.DeploymentMode
    "enrichment_file_name"       = "configuration/publish-enrichment-rules.json"
    "sofr_artifacts_bucket_name" = var.ArtifactsBucketName
    "sofr_input_bucket_name"     = var.SOFRInputFilesBucketName
    "sofr_output_bucket_name"    = var.SOFROutputFilesBucketName
    "repo_archival_folder_name"  = var.ArchivalFolderName
  }

  tags = {
    "2nd Level Support"          = var.Tag2ndLevelSupportValue
    "Application System CI Name" = var.TagappCiNameValue
    "CI Environment"             = var.TagCIEnvironmentValue
    "Created Date"               = var.TagcreatedDateValue
    "Information Classification" = var.TagdataClassificationValue
    "Department Code"            = var.TagDeptCodeValue
    "Line of Business"           = var.TaglobValue
    "Accounting Code"            = var.TagmanagedByValue
    "Tagging Version"            = var.TagtaggingVersionValue
  }
}


resource "aws_lb" "IntALB" {
  name               = "SofrIntALB-tf"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.devops-sg-markets-https-vpc1.id, data.aws_security_group.devops-sg-interfed-https-vpc1.id]
  subnets            = [data.aws_subnet.SUBNET-PUBLIC-AZ1-VPC1-ID.id, data.aws_subnet.SUBNET-PUBLIC-AZ2-VPC1-ID.id]

  enable_deletion_protection = false
  idle_timeout               = 120
  ip_address_type            = "ipv4"

  tags = {
    "2nd Level Support"          = var.Tag2ndLevelSupportValue
    "Application System CI Name" = var.TagappCiNameValue
    "CI Environment"             = var.TagCIEnvironmentValue
    "Created Date"               = var.TagcreatedDateValue
    "Information Classification" = var.TagdataClassificationValue
    "Department Code"            = var.TagDeptCodeValue
    "Line of Business"           = var.TaglobValue
    "Accounting Code"            = var.TagmanagedByValue
    "Tagging Version"            = var.TagtaggingVersionValue
  }
}


resource "aws_lb_listener" "IntALBListener" {
  load_balancer_arn = aws_lb.IntALB.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.IntCertArn
  default_action {
      type= "fixed-response"
      fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}

resource "aws_lambda_permission" "ALBNewSubsPerms" {
  action        = "lambda:InvokeFunction"
  function_name = module.NewSubsLambda.this_lambda_function_arn
  principal     = "elasticloadbalancing.amazonaws.com"
}

resource "aws_lb_target_group" "NewSubsTarget" {
  name        = "NewSubmissionsTarget-tf"
  target_type = "lambda"

  tags = {
    "2nd Level Support"          = var.Tag2ndLevelSupportValue
    "Application System CI Name" = var.TagappCiNameValue
    "CI Environment"             = var.TagCIEnvironmentValue
    "Created Date"               = var.TagcreatedDateValue
    "Information Classification" = var.TagdataClassificationValue
    "Department Code"            = var.TagDeptCodeValue
    "Line of Business"           = var.TaglobValue
    "Accounting Code"            = var.TagmanagedByValue
    "Tagging Version"            = var.TagtaggingVersionValue
  }
}

resource "aws_lb_target_group_attachment" "NewSubs" {
  target_group_arn = aws_lb_target_group.NewSubsTarget.arn
  target_id        = module.NewSubsLambda.this_lambda_function_arn
  depends_on       = [aws_lambda_permission.ALBNewSubsPerms]
}

resource "aws_lb_listener_rule" "IntALBListener" {
  listener_arn = aws_lb_listener.IntALBListener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.NewSubsTarget.arn
  }

  condition {
    path_pattern {
      values = ["/newsubs"]
    }
    http_request_method {
      values = ["GET", "HEAD"]
    }
  }
}

resource "aws_lambda_permission" "ALBSubIdPerms" {
  action        = "lambda:InvokeFunction"
  function_name = module.SubIdLambda.this_lambda_function_arn
  principal     = "elasticloadbalancing.amazonaws.com"
}

resource "aws_lb_target_group" "SubIdTarget" {
  name        = "SubmissionIdTarget-tf"
  target_type = "lambda"

  tags = {
    "2nd Level Support"          = var.Tag2ndLevelSupportValue
    "Application System CI Name" = var.TagappCiNameValue
    "CI Environment"             = var.TagCIEnvironmentValue
    "Created Date"               = var.TagcreatedDateValue
    "Information Classification" = var.TagdataClassificationValue
    "Department Code"            = var.TagDeptCodeValue
    "Line of Business"           = var.TaglobValue
    "Accounting Code"            = var.TagmanagedByValue
    "Tagging Version"            = var.TagtaggingVersionValue
  }
}

resource "aws_lb_target_group_attachment" "SubIdTarget-tf" {
  target_group_arn = aws_lb_target_group.SubIdTarget.arn
  target_id        = module.SubIdLambda.this_lambda_function_arn
  depends_on       = [aws_lambda_permission.ALBNewSubsPerms]
}

resource "aws_lb_listener_rule" "SubIdRule-tf" {
  listener_arn = aws_lb_listener.IntALBListener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.SubIdTarget.arn
  }

  condition {
    path_pattern {
      values = ["/subid"]
    }
    http_request_method {
      values = ["GET", "HEAD"]
    }
  }
}

resource "aws_route53_record" "IntDNSAlias" {
  zone_id = var.HostedZoneId
  name    = "${var.ApplicationName}-int.${data.aws_route53_zone.internal.name}"
  type    = "A"

  alias {
    name                   = aws_lb.IntALB.dns_name
    zone_id                = aws_lb.IntALB.zone_id
    evaluate_target_health = true
  }
}
