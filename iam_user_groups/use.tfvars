user_name   = "route_53_cirtificate"
group_name  = "route_53_cirtificate_group"
policy_name = "route_53_cirtificate_policy"

statements = [
  {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  },
  {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/Z08869203B6DBIGRWHMDG"]
  },
  {
    effect    = "Allow"
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
]