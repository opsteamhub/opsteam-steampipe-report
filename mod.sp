locals {
  aws_common_tags = {
    service = "AWS"
  }
}

mod "opsteam_insights" {
  # hub metadata
  title         = "Ops Team AWS Report"
  description   = "Create dashboards and reports for your AWS resources using Steampipe."
  color         = "#FF9900"
  icon          = "/images/mods/turbot/aws-insights.svg"
  categories    = ["aws", "dashboard", "public cloud"]

  opengraph {
    title       = "Steampipe Mod for AWS"
    description = "Create dashboards and reports for your AWS resources using Steampipe."
    image       = "/images/mods/turbot/aws-insights-social-graphic.png"
  }

}