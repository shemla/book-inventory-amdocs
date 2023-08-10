# continue of cognito.tf file
# The policy that is needed to enable authenticated cognito users assume roles based on their user group
data "aws_iam_policy_document" "group_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_user_pool_client.cognito_client.id] #todo: this line might be wrong
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

locals {
  custom_role_trust_policy_var = data.aws_iam_policy_document.group_role.json
}

# the IAM roles that the users groups will assume
module "sysadmins_group_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  custom_role_trust_policy = local.custom_role_trust_policy_var
  role_name = "sysadmins_group_role"
  #role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  number_of_custom_role_policy_arns = 1
}

module "managers_group_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  custom_role_trust_policy = local.custom_role_trust_policy_var
  role_name = "managers_group_role"
  #role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  number_of_custom_role_policy_arns = 1
}


module "employees_group_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  custom_role_trust_policy = local.custom_role_trust_policy_var
  role_name = "employees_group_role"
  #role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  number_of_custom_role_policy_arns = 1
}



module "users_group_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  custom_role_trust_policy = local.custom_role_trust_policy_var
  role_name = "users_group_role"
  #role_requires_mfa = false

}




# user groups
resource "aws_cognito_user_group" "sysadmins" {
  name         = "sysadmins"
  user_pool_id = module.aws_cognito_user_pool_complete.id
  description  = "A group of system admins with the maximum permissions of the system"
  precedence   = 1
  role_arn     = module.sysadmins_group_role.iam_role_arn
}

resource "aws_cognito_user_group" "managers" {
  name         = "managers"
  user_pool_id = module.aws_cognito_user_pool_complete.id
  description  = "A group of branch managers"
  precedence   = 2
  role_arn     = module.managers_group_role.iam_role_arn
}


resource "aws_cognito_user_group" "employees" {
  name         = "employees"
  user_pool_id = module.aws_cognito_user_pool_complete.id
  description  = "A group of simple employees"
  precedence   = 3
  role_arn     = module.employees_group_role.iam_role_arn
}


resource "aws_cognito_user_group" "users" {
  name         = "users"
  user_pool_id = module.aws_cognito_user_pool_complete.id
  description  = "The default users group"
  precedence   = 100
  role_arn     = module.users_group_role.iam_role_arn
}

# create the first cognito user
resource "aws_cognito_user" "cognito_user" {
  user_pool_id = module.aws_cognito_user_pool_complete.id
  username     = "sysadmin_main_user"

  attributes = {
    displayName      = "System Administrator"
    branch           = "0"
    email            = var.response_email
    email_verified   = true
  }
}

# add user to the sysadmins group
resource "aws_cognito_user_in_group" "add_first_sysadmin_user" {
  user_pool_id = module.aws_cognito_user_pool_complete.id
  group_name   = aws_cognito_user_group.sysadmins.name
  username     = aws_cognito_user.cognito_user.username
}
 