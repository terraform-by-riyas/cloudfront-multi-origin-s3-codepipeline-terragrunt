resource "aws_codepipeline" "codepipeline" {
  name     = var.codepipeline_name # <client_name>-<environment>-<project_name>-pipeline
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.artifact_bucket_primary
    type     = "S3"
    region = "us-east-1"

    # encryption_key {
    #   id   = data.aws_kms_alias.s3kmskey.arn
    #   type = "KMS"
    # }
  }
    artifact_store {
    location = var.artifact_bucket_failover
    type     = "S3"
    region = "us-east-2"
    

    # encryption_key {
    #   id   = data.aws_kms_alias.s3kmskey.arn
    #   type = "KMS"
    # }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.aws_codestarconnections_connection_arn
        FullRepositoryId = var.FullRepositoryId
        BranchName       = var.BranchName
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }

  stage {
    name = "Deploy"
    
    action {
      name            = "Primary_Origin"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        BucketName = var.primary_bucket_name         // Variables
        Extract = "true"
      }
    }
    action {
      name            = "Failover_Origin"
      category        = "Deploy"
      owner           = "AWS"
      region          = "us-east-2"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        BucketName = var.failover_bucket_name       // Variables
        Extract = "true"
      }
    }
  }
}

# resource "aws_s3_bucket" "codepipeline_bucket" {
# // Create a bucket to store artifat
#   bucket = var.artifact_bucket_primary  // create a bucket in the primary region to store artifacts.
# }
# resource "aws_s3_bucket" "codepipeline_bucket_failover" {
# // Create a bucket to store artifat
#   bucket = var.artifact_bucket_failover  // create a bucket in the failover region to store artifacts.
# }


# resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
#   bucket = aws_s3_bucket.codepipeline_bucket.id             
#   acl    = "private"
# }


# data "aws_kms_alias" "s3kmskey" {
#   name = "alias/myKmsKey"
# }

/////////////////////////////////////////////////////////////////////////
resource "aws_iam_role" "codepipeline_role" {
// creates a role with Trust Relation
  name = "${var.environment}-${var.project}-${var.codepipeline_name}-role"      // variable
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
//create a policy and attach to the above role.
  name = "dev-angular-16-pipeline_policy"
  role = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_role_policy_document.json
}

data "aws_iam_policy_document" "codepipeline_role_policy_document" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:PassRole"]

    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"

      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["codestar-connections:UseConnection"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "opsworks:CreateDeployment",
      "opsworks:DescribeApps",
      "opsworks:DescribeCommands",
      "opsworks:DescribeDeployments",
      "opsworks:DescribeInstances",
      "opsworks:DescribeStacks",
      "opsworks:UpdateApp",
      "opsworks:UpdateStack",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "devicefarm:ListProjects",
      "devicefarm:ListDevicePools",
      "devicefarm:GetRun",
      "devicefarm:GetUpload",
      "devicefarm:CreateUpload",
      "devicefarm:ScheduleRun",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "servicecatalog:ListProvisioningArtifacts",
      "servicecatalog:CreateProvisioningArtifact",
      "servicecatalog:DescribeProvisioningArtifact",
      "servicecatalog:DeleteProvisioningArtifact",
      "servicecatalog:UpdateProduct",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["cloudformation:ValidateTemplate"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ecr:DescribeImages"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "states:DescribeExecution",
      "states:DescribeStateMachine",
      "states:StartExecution",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment",
    ]
  }
}

/////////////////////////////////CODE-BUILD PROJECT///////////////////////////

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_project" {
//create a role
  name               = "${var.environment}-${var.project}-${var.CodeBuildName}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
// attach the assume role
}

resource "aws_iam_role_policy_attachment" "codebuild_ssm_attach" {
  role       = aws_iam_role.codebuild_project.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

data "aws_iam_policy_document" "codebuild_project" { // https://flosell.github.io/iam-policy-json-to-terraform/
  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["${var.artifact_bucket_primary_arn}*", "${var.artifact_bucket_failover_arn}*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["${var.artifact_bucket_primary_arn}*", "${var.artifact_bucket_failover_arn}*"]

    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_project" {
// attache the codebuild policy to the codebuild role. It has now the assume+policy
  role   = aws_iam_role.codebuild_project.name
  policy = data.aws_iam_policy_document.codebuild_project.json
}

resource "aws_codebuild_project" "codebuild_project" {
//Start creating the codeBuild project
  name          = var.CodeBuildName                                        //VARIABLE
  description   = "Build project for the ${var.environment} ${var.project}"                                 //VARIABLE
  build_timeout = "30"  
  service_role  = aws_iam_role.codebuild_project.arn

  artifacts {
    encryption_disabled    = false
    name                   = "${var.environment}-${var.project}-build"                  //VARIABLE
    override_artifact_name = false
    packaging              = "ZIP"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE" //https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {     #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#type      
      name  = "GIT_BRANCH"
      value = "#{SourceVariables.BranchName}"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "GIT_COMMIT_ID"
      value = "#{SourceVariables.CommitId}"
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "ENVIRONMENT"
      value = "dev"                                  // variable
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "BASE_API_URL"
      value = "https://api.dev.aws.acpdecisions.org"         // variable
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group_codebuild_project_dev_angular"             // variable
      stream_name = "log-stream_codebuild_project_dev_angular"           // variable
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.artifact_bucket_primary}/${var.environment}-${var.project}-build-log"      // variable
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec           = var.buildspecName
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
  }

  // source_version = "master"

  tags = {
    Name = "${var.environment}-${var.project}"
  }
}