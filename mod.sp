locals {
  aws_common_tags = {
    service = "AWS"
  }
}

mod "opsteam_insights" {
  # hub metadata
  title         = "Ops Team Security Assessment Report"
  description   = "Security Assessment Report."
  color         = "#FF9900"
  icon          = "/images/mods/turbot/aws-insights.svg"
  categories    = ["aws", "dashboard", "public cloud", "security"]

  opengraph {
    title       = "Steampipe Mod for AWS"
    description = "Security Assessment Report."
    image       = "/images/mods/turbot/aws-insights-social-graphic.png"
  }

}
