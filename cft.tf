resource "aws_cloudformation_stack" "local_readonly" {
  name             = "nyl-${var.lob}-${var.env}-wiz-local-readonly"
  template_url     = "https://wizio-public.s3.us-east-2.amazonaws.com/deployment-v2/aws/wiz-aws-read-only.json"
  disable_rollback = false
  capabilities = [
    "CAPABILITY_NAMED_IAM",
  ]
  parameters = {
    ExternalId = var.wiz_external_id
  }
}

resource "aws_cloudformation_stack" "local_scanner" {
  name             = "nyl-${var.lob}-${var.env}-wiz-local-scanner"
  template_url     = "https://wizio-public.s3.us-east-2.amazonaws.com/deployment-v2/aws/wiz-aws-scanner.json"
  disable_rollback = false
  capabilities = [
    "CAPABILITY_NAMED_IAM",
  ]
  parameters = {
    ExternalId            = var.wiz_external_id
    OrchestratorAccountID = var.wiz_outpost_account_id
    RoleSuffix            = var.lob
  }
}

resource "aws_cloudformation_stack_set" "org_readonly" {
  name             = "nyl-${var.lob}-${var.env}-wiz-org-readonly"
  description      = "Wiz AWS standard deployment"
  template_url     = "https://wizio-public.s3.us-east-2.amazonaws.com/deployment-v2/aws/wiz-aws-read-only.json"
  permission_model = "SERVICE_MANAGED"
  capabilities = [
    "CAPABILITY_NAMED_IAM",
  ]
  auto_deployment {
    enabled = true
  }
  parameters = {
    ExternalId  = var.wiz_external_id
    WizRoleName = "WizAccess-Role"
  }
  timeouts {
    update = "4h"
  }
  lifecycle {
    ignore_changes = [
      administration_role_arn,
    ]
  }
}

resource "aws_cloudformation_stack_set" "org_scanner" {
  name             = "nyl-${var.lob}-${var.env}-wiz-org-scanner"
  description      = "Wiz AWS disk scanner deployment"
  template_url     = "https://wizio-public.s3.us-east-2.amazonaws.com/deployment-v2/aws/wiz-aws-scanner.json"
  permission_model = "SERVICE_MANAGED"
  capabilities = [
    "CAPABILITY_NAMED_IAM",
  ]
  auto_deployment {
    enabled = true
  }
  parameters = {
    ExternalId            = var.wiz_external_id
    OrchestratorAccountID = var.wiz_outpost_account_id
    RoleSuffix            = var.lob
  }
  timeouts {
    update = "4h"
  }
  lifecycle {
    ignore_changes = [
      administration_role_arn,
    ]
  }
}

resource "aws_cloudformation_stack_set_instance" "org_readonly" {
  region         = data.aws_region.current.name
  stack_set_name = aws_cloudformation_stack_set.org_readonly.name
  deployment_targets {
    organizational_unit_ids = [
      var.organization_id,
    ]
  }
  timeouts {
    create = "4h"
    update = "4h"
    delete = "4h"
  }
}

resource "aws_cloudformation_stack_set_instance" "org_scanner" {
  region         = data.aws_region.current.name
  stack_set_name = aws_cloudformation_stack_set.org_scanner.name
  deployment_targets {
    organizational_unit_ids = [
      var.organization_id,
    ]
  }
  timeouts {
    create = "4h"
    update = "4h"
    delete = "4h"
  }
}

resource "aws_cloudformation_stack_set" "org_auto_rem_ca_role" {
  name        = "nyl-${var.lob}-${var.env}-wiz-org-auto-rem-ca-role"
  description = "Wiz AWS Auto Remediation CrossAccountRole deployment"
  #template_url     = "https://wizio-public.s3.us-east-2.amazonaws.com/deployment-v2/aws/remediation/cft/cft_cross_account_role.json" # orignal url for wiz auto rem cr role
  template_body    = file("${path.module}/cft-template/cft_cross_account_role_v1.json") # customized cft template with prunned premissions for wiz auto rem cr role
  permission_model = "SERVICE_MANAGED"
  capabilities = [
    "CAPABILITY_NAMED_IAM",
  ]
  auto_deployment {
    enabled = true
  }
  parameters = {
    AWSMainAccountId = var.wiz_outpost_account_id
  }
  timeouts {
    update = "4h"
  }
  lifecycle {
    ignore_changes = [
      administration_role_arn,
    ]
  }
}

resource "aws_cloudformation_stack_set_instance" "org_auto_rem_ca_role" {
  region         = data.aws_region.current.name
  stack_set_name = aws_cloudformation_stack_set.org_auto_rem_ca_role.name
  deployment_targets {
    organizational_unit_ids = [
      var.organization_id,
    ]
  }
  timeouts {
    create = "4h"
    update = "4h"
    delete = "4h"
  }
}
