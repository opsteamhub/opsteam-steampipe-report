 query "account_count" {
  sql = <<-EOQ
    select
      count(*) as "Accounts"
    from
      aws_account;
  EOQ
}

 query "account_part_of_organizations" {
  sql = <<-EOQ
    select
      account_id as "Account",
      case
        when organization_id is not null then 'ok'
        else 'alarm'
      end as "Status",
      case
        when organization_id is not null then title || ' is part of organization(s).'
        else title || ' is not part of organization.'
      end as "Reason",
      region as "Region",
      account_id as "Account ID"
    from
      aws_account;
  EOQ
}

query "account_table" {
  sql = <<-EOQ
    select
      account_id as "Account ID",
      account_aliases ->> 0 as "Alias",
      organization_id as "Organization ID",
      organization_master_account_email as "Organization Master Account Email",
      organization_master_account_id as "Organization Master Account ID",
      arn as "ARN"
    from
      aws_account;
  EOQ
}

### IAM ###

query "iam_root_access_keys_count" {
  sql = <<-EOQ
    select
      sum(account_access_keys_present) as value,
      'Root Access Keys' as label,
      case when sum(account_access_keys_present) = 0 then 'ok' else 'alert' end as type
    from
      aws_iam_account_summary;
  EOQ
}
