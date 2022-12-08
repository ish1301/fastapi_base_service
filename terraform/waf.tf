resource "aws_wafv2_web_acl" "default" {
  name        = "${var.app}-${var.env}-waf-acl"
  description = "Default rule set for WAF"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "SizeRestrictions_BODY"
        }

        excluded_rule {
          name = "CrossSiteScripting_BODY"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
    }
  }


  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
     }
  }

  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
    }
  }

  tags = {
    Name       = "${var.app}-${var.env}-acl"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.app}-${var.env}-waf"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "backend" {
  resource_arn = aws_lb.amp_main.arn
  web_acl_arn  = aws_wafv2_web_acl.default.arn
}

resource "aws_wafv2_web_acl_association" "ui" {
  resource_arn = aws_lb.amp_ui_main.arn
  web_acl_arn  = aws_wafv2_web_acl.default.arn
}
