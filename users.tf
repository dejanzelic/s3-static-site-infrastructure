provider "aws" {
  region     = "us-west-2"
}

#Create user

#aws only allows IAM users to assume a role not a group
data "aws_iam_policy_document" "admin-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/user"]
    }
  }
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 20
  require_lowercase_characters   = true
  require_numbers                = false
  require_uppercase_characters   = true
  require_symbols                = false
  allow_users_to_change_password = true
}

resource "aws_iam_user" "user" {
  name          = "user"
  path          = "/"
  force_destroy = true
}

resource "aws_iam_group" "admins" {
  name = "admins"
  path = "/users/"
}

resource "aws_iam_user_login_profile" "user" {
  user    = "${aws_iam_user.user.name}"
  pgp_key = "keybase:dejandayoff"
}

resource "aws_iam_group_policy_attachment" "readonly_attach" {
    group       = "${aws_iam_group.admins.name}"
    policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_membership" "admins" {
  name = "admins-membership"

  users = [
    "${aws_iam_user.user.name}",
  ]

  group = "${aws_iam_group.admins.name}"
}

resource "aws_iam_role" "poweruser_role" {
  name               = "poweruser_role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.admin-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "poweruser-attach" {
    role       = "${aws_iam_role.poweruser_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

#Output variables
output "password" {
  value = "${aws_iam_user_login_profile.user.encrypted_password}"
}

data "aws_caller_identity" "current" {}
output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

