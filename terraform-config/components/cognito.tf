# In this file:
# user pools
# signup-related functions
# signin related functions
# reset password related functions
# create first user that can invite other users. 


module "aws_cognito_user_pool_complete" {
  source  = "lgallard/cognito-user-pool/aws"
  user_pool_name           = "book_inventory_users"

  alias_attributes         = ["email", "phone_number"]
  auto_verified_attributes = ["email"]

  deletion_protection = "ACTIVE"

  # onboarding experience
  admin_create_user_config = {
    email_subject = "Here, your link to join our book inventory"
  }

  verification_message_template_default_email_option  = "CONFIRM_WITH_LINK"
  verification_message_template_email_message_by_link = "`{##Click Here##}`"

  # password preferences
  password_policy = {
    minimum_length                   = 10
    require_lowercase                = false
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = 14
  }


  recovery_mechanisms = [
     {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]

# attributes of the user model
  schemas = [
    {
      attribute_data_type      = "Boolean"
      developer_only_attribute = false
      mutable                  = true
      name                     = "available"
      required                 = false
    },
    {
      attribute_data_type      = "Boolean"
      developer_only_attribute = true
      mutable                  = true
      name                     = "registered"
      required                 = false
    }
  ]

  string_schemas = [
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      name                     = "email"
      required                 = true

      string_attribute_constraints = {
        min_length = 7
        max_length = 25
      }
    },
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      name                     = "branch"
      required                 = false

      string_attribute_constraints = {
        min_length = 1
        max_length = 50
      }
    },
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      name                     = "displayName"
      required                 = false

      string_attribute_constraints = {
        min_length = 1
        max_length = 50
      }
    },
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      name                     = "contactInfo"
      required                 = false

      string_attribute_constraints = {
        min_length = 1
        max_length = 500
      }
    }
  ]
}

# create a client to the user pool so it will be able to integrate with web application
resource "aws_cognito_user_pool_client" "cognito_client" {
  name = "cognito_client_book_inventory"
  generate_secret = true
  
  callback_urls                        = ["https://bookteam.net/callback"]
  default_redirect_uri                 = "https://bookteam.net/callback"
      
  user_pool_id = module.aws_cognito_user_pool_complete.id
}

