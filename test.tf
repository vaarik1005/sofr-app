Replace line 174 - 218
resource "aws_lambda_function" "NewSubsLambda" {
  function_name      = "devops_SofrNewSubmissions_tf"
  description        = "SOFR New Submissions Query Lambda Function"
  handler            = "org.frb.ny.mods.ofr.lambda.handler.SofrFileHandler::handleRequest"
  runtime            = "java8"
  publish            = true
  memory_size        = 1024
  kms_key_arn        = data.aws_kms_key.lambda_kms_key.arn
  role               = module.devops-query-lambdas-role.this_iam_role_name
  timeout            = 30
  s3_bucket          = var.DeploymentBucketName
  s3_key             = "functions/${var.LambdaNewSubmissionsLoc}"
  security_group_ids = [data.aws_security_group.SG-OUT-ONLY-VPC1-ID.id]
  subnet_ids         = [data.aws_subnet.SUBNET-PRIVATE-AZ1-VPC1-ID.id, data.aws_subnet.SUBNET-PRIVATE-AZ2-VPC1-ID.id]

  environment {
    variables = {
      deployment_mode            = var.DeploymentMode
      enrichment_file_name       = "configuration/publish-enrichment-rules.json"
      sofr_artifacts_bucket_name = var.ArtifactsBucketName
      sofr_input_bucket_name     = var.SOFRInputFilesBucketName
      sofr_output_bucket_name    = var.SOFROutputFilesBucketName
      repo_archival_folder_name  = var.ArchivalFolderName
    }
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

Replace line 308
function_name = module.NewSubsLambda.this_lambda_function_arn
function_name = aws_lambda_function.NewSubsLambda.arn

Replace line 331
target_id        = module.NewSubsLambda.this_lambda_function_arn
target_id        = aws_lambda_function.NewSubsLambda.arn
