query "dynamodb_table_default_encryption" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Encrypted with Default Key' as label
    from
      aws_dynamodb_table
    where
      sse_description is null
      or sse_description ->> 'SSEType' is null;
  EOQ
}

query "dynamodb_table_aws_managed_key_encryption" {
  sql = <<-EOQ
    select
      count(*) as value,
      case count(*) when 0 then 'alert' else 'ok' end as type,
      'Encrypted with AWS Managed Key' as label
    from
      aws_dynamodb_table as t,
      aws_kms_key as k
    where
      k.arn = t.sse_description ->> 'KMSMasterKeyArn'
      and sse_description is not null
      and sse_description ->> 'SSEType' = 'KMS'
      and k.key_manager = 'AWS';
  EOQ
}

query "dynamodb_table_customer_managed_key_encryption" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Encrypted with CMK' as label
    from
      aws_dynamodb_table as t,
      aws_kms_key as k
    where
      k.arn = t.sse_description ->> 'KMSMasterKeyArn'
      and sse_description is not null
      and sse_description ->> 'SSEType' = 'KMS'
      and k.key_manager = 'CUSTOMER';
  EOQ
}

query "dynamodb_table_encryption_table" {
  sql = <<-EOQ
    SELECT
      name AS "Table",
      CASE
        WHEN sse_description IS NULL THEN 'alarm'
        ELSE 'ok'
      END AS "Status",
      CASE
        WHEN sse_description IS NULL THEN 'encrypted with KMS'
        ELSE 'encrypted with KMS.'
      END AS "Reason",
      region AS "Region",
      account_id AS "Account ID"
    FROM
      aws_dynamodb_table;
  EOQ
}

query "dynamodb_table_count" {
  sql = <<-EOQ
    select count(*) as "Tables" from aws_dynamodb_table;
  EOQ
}

query "dynamodb_table_point_in_time_recovery_enabled" {
  sql = <<-EOQ
    SELECT
      name AS "Table",
      CASE
        WHEN lower(point_in_time_recovery_description ->> 'PointInTimeRecoveryStatus') = 'disabled' THEN 'alarm'
        ELSE 'ok'
      END AS "Status",
      CASE
        WHEN lower(point_in_time_recovery_description ->> 'PointInTimeRecoveryStatus') = 'disabled' THEN 'point-in-time recovery not enabled'
        ELSE 'point-in-time recovery enabled'
      END AS "Reason",
      region AS "Region",
      account_id AS "Account ID"
    FROM
      aws_dynamodb_table;

  EOQ
}


