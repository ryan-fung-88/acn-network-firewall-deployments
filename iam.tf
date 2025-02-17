data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "test-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "ssm_policy" {
  name = "AmazonEC2RoleforSSM"
}

resource "aws_iam_policy" "iam_ssm_policy" {
  name        = "ssm_policy_ec2"
  description = "SSM policy for EC2"
  policy      = data.aws_iam_policy.ssm_policy.policy
}

resource "aws_iam_role_policy_attachment" "policy_to_role_attachment" {
  role      = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.iam_ssm_policy.arn
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.ec2_role.name
}


