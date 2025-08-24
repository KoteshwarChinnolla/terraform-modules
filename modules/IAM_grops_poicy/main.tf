data "aws_iam_policy_document" "example" {
  dynamic "statement" {
    for_each = var.statements
    content {
      actions   = statement.value.actions
      resources = statement.value.resources
      effect    = statement.value.effect
    }
  }
}

resource "aws_iam_group" "group1" {
  name = var.group_name
}

resource "aws_iam_user" "user1" {
  name = var.user_name
}

resource "aws_iam_user_group_membership" "example2" {
  user   = aws_iam_user.user1.name
  groups = [aws_iam_group.group1.name]
}

resource "aws_iam_policy" "group_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.example.json
}

resource "aws_iam_group_policy_attachment" "attach_group_policy" {
  group      = aws_iam_group.group1.name
  policy_arn = aws_iam_policy.group_policy.arn
}


resource "aws_iam_access_key" "user1_key" {
  user = aws_iam_user.user1.name
}
