resource "aws_iam_user" "vault_validation" {
  name = "vault_validation"
  path = "/${data.terraform_remote_state.vault.environment_name}/"
}

resource "aws_iam_access_key" "vault" {
  user = "${aws_iam_user.vault_validation.name}"
}

resource "aws_iam_user_policy" "vault_ro" {
  name = "vault_validation_policy"
  user = "${aws_iam_user.vault_validation.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
