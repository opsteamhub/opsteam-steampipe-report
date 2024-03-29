### S3 ###

query "s3_bucket_public_read_access_table" {
  sql = <<-EOQ
    WITH public_acl AS (
      SELECT
        DISTINCT name
      FROM
        aws_s3_bucket,
        jsonb_array_elements(acl -> 'Grants') AS grants
      WHERE
        (
          grants -> 'Grantee' ->> 'URI' = 'http://acs.amazonaws.com/groups/global/AllUsers'
          OR grants -> 'Grantee' ->> 'URI' = 'http://acs.amazonaws.com/groups/global/AuthenticatedUsers'
        )
        AND (
          grants ->> 'Permission' = 'FULL_CONTROL'
          OR grants ->> 'Permission' = 'READ_ACP'
          OR grants ->> 'Permission' = 'READ'
        )
    ),
    read_access_policy AS (
      SELECT
        DISTINCT name
      FROM
        aws_s3_bucket,
        jsonb_array_elements(policy_std -> 'Statement') AS s,
        jsonb_array_elements_text(s -> 'Action') AS action
      WHERE
        s ->> 'Effect' = 'Allow'
        AND (
          s -> 'Principal' -> 'AWS' = '["*"]'
          OR s ->> 'Principal' = '*'
        )
        AND (
          action = '*'
          OR action = '*:*'
          OR action = 's3:*'
          OR action ILIKE 's3:get%'
          OR action ILIKE 's3:list%'
        )
    )
    SELECT
      name as "Bucket",
      status as "Status",
      reason as "Reason",
      region as "Region",
      account_id as "Account ID"
    FROM (
      SELECT
        b.name AS name,
        CASE
          WHEN (
            block_public_acls
            OR a.name IS NULL
          )
          AND NOT bucket_policy_is_public THEN 'ok'
          WHEN (
            block_public_acls
            OR a.name IS NULL
          )
          AND (
            bucket_policy_is_public
            AND block_public_policy
          ) THEN 'ok'
          WHEN (
            block_public_acls
            OR a.name IS NULL
          )
          AND (
            bucket_policy_is_public
            AND p.name IS NULL
          ) THEN 'ok'
          ELSE 'alarm'
        END AS status,
        CASE
          WHEN (
            block_public_acls
            OR a.name IS NULL
          )
          AND NOT bucket_policy_is_public THEN  ' not publicly readable.'
          WHEN (
            block_public_acls
            OR a.name IS NULL
          )
          AND (
            bucket_policy_is_public
            AND block_public_policy
          ) THEN  ' not publicly readable.'
          WHEN (
            block_public_acls
            OR a.name IS NULL
          )
          AND (
            bucket_policy_is_public
            AND p.name IS NULL
          ) THEN  ' not publicly readable.'
          ELSE  ' publicly readable.'
        END AS reason,
        b.region,
        b.account_id
      FROM
        aws_s3_bucket AS b
        LEFT JOIN public_acl AS a ON b.name = a.name
        LEFT JOIN read_access_policy AS p ON b.name = p.name
    ) AS subquery
    WHERE status = 'alarm';

  EOQ
}

query "s3_bucket_public_write_access_table" {
  sql = <<-EOQ
    WITH data AS (
      SELECT
        DISTINCT name
      FROM
        aws_s3_bucket,
        jsonb_array_elements(acl -> 'Grants') AS grants
      WHERE
        grants -> 'Grantee' ->> 'URI' = 'http://acs.amazonaws.com/groups/global/AllUsers'
        AND (
          grants ->> 'Permission' = 'FULL_CONTROL'
          OR grants ->> 'Permission' = 'WRITE_ACP'
        )
    )
    SELECT
      b.arn AS "Bucket",
      'alarm' AS "Status",
      b.title || ' publicly writable.' AS "Reason",
      b.region AS "Region",
      b.account_id AS "Account ID"
    FROM
      aws_s3_bucket AS b
      INNER JOIN data AS d ON b.name = d.name;
  EOQ
}

query "s3_public_access_block_bucket_table" {
  sql = <<-EOQ
    SELECT
      name AS "Bucket",
      'alarm' AS "Status",
      concat_ws(
        ', ',
        CASE
          WHEN NOT block_public_acls THEN 'block_public_acls'
        END,
        CASE
          WHEN NOT block_public_policy THEN 'block_public_policy'
        END,
        CASE
          WHEN NOT ignore_public_acls THEN 'ignore_public_acls'
        END,
        CASE
          WHEN NOT restrict_public_buckets THEN 'restrict_public_buckets'
        END
      ) || '.' AS "Reason",
      region,
      account_id AS "Account ID"
    FROM
      aws_s3_bucket
    WHERE NOT (
      block_public_acls
      AND block_public_policy
      AND ignore_public_acls
      AND restrict_public_buckets
    );
  EOQ
}

query "s3_bucket_public_access_blocked" {
  sql = <<-EOQ
    with public_block_status as (
      select
        case
          when block_public_acls
          and block_public_policy
          and ignore_public_acls
          and restrict_public_buckets then 'blocked'
          else 'not blocked'
        end as block_status
      from
        aws_s3_bucket
    )
    select
      block_status,
      count(*)
    from
      public_block_status
    group by
      block_status;
  EOQ
}

query "s3_bucket_by_default_encryption_status" {
  sql = <<-EOQ
    with default_encryption as (
      select
        case when server_side_encryption_configuration is not null then 'enabled' else 'disabled'
        end as visibility
      from
        aws_s3_bucket
    )
    select
      visibility,
      count(*)
    from
      default_encryption
    group by
      visibility;
  EOQ
}

query "s3_bucket_logging_status" {
  sql = <<-EOQ
    with logging_status as (
      select
        case when logging -> 'TargetBucket' is not null then 'enabled' else 'disabled'
        end as visibility
      from
        aws_s3_bucket
    )
    select
      visibility,
      count(*)
    from
      logging_status
    group by
      visibility;
      EOQ
}

query "s3_bucket_versioning_mfa_status" {
  sql = <<-EOQ
    with versioning_mfa_status as (
      select
        case
          when versioning_mfa_delete then 'enabled' else 'disabled'
        end as visibility
      from
        aws_s3_bucket
    )
    select
      visibility,
      count(*)
    from
      versioning_mfa_status
    group by
      visibility;
  EOQ
}

query "s3_bucket_versioning_status" {
  sql = <<-EOQ
    with versioning_status as (
      select
        case
          when versioning_enabled then 'enabled' else 'disabled'
        end as visibility
      from
        aws_s3_bucket
    )
    select
      visibility,
      count(*)
    from
      versioning_status
    group by
      visibility;
  EOQ
}