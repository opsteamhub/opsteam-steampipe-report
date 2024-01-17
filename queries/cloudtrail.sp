query "cloudtrail_trail_enabled_account" {
  sql = <<-EOQ
    with trails_enabled_account as (
      select
        account_id,
        count(*) as num
      from
        aws_cloudtrail_trail
      where
        home_region = region
        and is_logging
      group by
        account_id
    )
    select
      a.arn as "Trail",
      case
        when b.num > 0 then 'ok'
        else 'alarm'
      end as "Status",
      case
        when b.num > 0 then a.title || ' has ' || b.num || ' trails enabled.'
        else a.title || ' has no trail enabled.'
      end as "Reason",
      a.region as "Region",
      a.account_id as "Account ID"
    from
      aws_account as a
      left join trails_enabled_account b on a.account_id = b.account_id;
  EOQ
}

query "cloudtrail_trail_validation_enabled" {
  sql = <<-EOQ
    select
      arn as resource,
      case
        when log_file_validation_enabled then 'ok'
        else 'alarm'
      end as status,
      case
        when log_file_validation_enabled then title || ' log file validation enabled.'
        else title || ' log file validation disabled.'
      end as reason,
      region,
      account_id
    from
      aws_cloudtrail_trail
    where
      region = home_region;
  EOQ
}

query "cloudtrail_trail_bucket_mfa_enabled" {
  sql = <<-EOQ
    select
      t.arn as resource,
      case
        when t.s3_bucket_name is null then 'alarm'
        when b.versioning_mfa_delete then 'ok'
        else 'alarm'
      end as status,
      case
        when t.s3_bucket_name is null then t.title || ' logging disabled.'
        when b.versioning_mfa_delete then t.title || t.s3_bucket_name || ' MFA enabled.'
        else t.title || t.s3_bucket_name || ' MFA disabled.'
      end as reason,
      t.region,
      t.account_id
    from
      aws_cloudtrail_trail t
      left join aws_s3_bucket b on t.s3_bucket_name = b.name
    where
      t.region = t.home_region;
  EOQ
}