
query "iam_accounts_without_root_mfa" {
  sql = <<-EOQ
    select
      count(*) filter (where not account_mfa_enabled) as value,
      'Accounts Without Root MFA' as label,
      case when count(*) filter (where not account_mfa_enabled) = 0 then 'ok' else 'alert' end as type
    from
      aws_iam_account_summary;
  EOQ
}

query "iam_root_access_keys_table" {
  sql = <<-EOQ
    select
      a.title as "Account",
      s.account_id as "Account ID",
      s.account_access_keys_present as "Root Keys",
      account_mfa_enabled as "Root MFA Enabled"
    from
      aws_iam_account_summary as s,
      aws_account as a
    where
      a.account_id = s.account_id
    order by
      a.title;
  EOQ
}

/*
 TODO: Can we find root logins in cloudtrail events??
  - join with cloudtrail table to find the log group?
  - bug: https://github.com/turbot/steampipe-plugin-aws/issues/902

select
  event_name,
  event_type,
  event_time,
  aws_region,
  error_code,
  error_message,
  event_id,
  user_type,
  additional_event_data,
  response_elements,
  jsonb_pretty(cloudtrail_event)
from
  aws_cloudtrail_trail_event
where
  log_group_name = 'aws-cloudtrail-logs' and event_name = 'ConsoleLogin'
*/

query "iam_access_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Access Keys' as label
    from
      aws_iam_access_key;
  EOQ
}

query "iam_access_key_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      aws_iam_access_key
    where
      create_date > now() - '1 days' :: interval;
  EOQ
}

query "iam_access_key_30_days_count" {
  sql = <<-EOQ
     select
        count(*) as value,
        '1-30 Days' as label
      from
        aws_iam_access_key
      where
        create_date between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "iam_access_key_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      aws_iam_access_key
    where
      create_date between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "iam_access_key_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      aws_iam_access_key
    where
      create_date between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "iam_access_key_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      aws_iam_access_key
    where
      create_date <= now() - '1 year' :: interval;
  EOQ
}

query "iam_access_key_age_table" {
  sql = <<-EOQ
    with access_key as (
      select
        k.user_name as user,
        u.arn as user_arn,
        k.access_key_id as access_key_id,
        k.status as status,
        now()::date - k.create_date::date as age_in_days,
        k.create_date as create_date,
        k.account_id as account_id
      from
        aws_iam_access_key as k,
        aws_iam_user as u
      where
        u.name = k.user_name
      )
      select
        ak.user as "User",
        ak.access_key_id as "Access Key ID",
        ak.age_in_days as "Age in Days",
        ak.create_date as "Create Date",
        ak.status as "Status",
        ak.user_arn as "User ARN",
        a.title as "Account",
        ak.account_id as "Account ID"
      from
        access_key as ak,
        aws_account as a
      where
        a.account_id = ak.account_id
      order by
        ak.create_date,
        ak.user;
  EOQ
}

query "iam_role_no_administrator_access_policy_attached_table" {
  sql = <<-EOQ
    WITH admin_roles AS (
      SELECT
        arn,
        name,
        attachments
      FROM
        aws_iam_role,
        jsonb_array_elements_text(attached_policy_arns) AS attachments
      WHERE
        split_part(attachments, '/', 2) = 'AdministratorAccess'
    )

    SELECT
      r.name AS "Role Name",
      'alarm' AS "Status",
      ' has AdministratorAccess policy attached.' AS "Reason",
      r.region AS "Region",
      r.account_id AS "Account ID"
    FROM
      aws_iam_role AS r
      JOIN admin_roles ar ON r.arn = ar.arn
    ORDER BY
      r.name;
  EOQ
}


query "iam_user_with_administrator_access_mfa_enabled_table" {
  sql = <<-EOQ
    WITH admin_users AS (
      SELECT
        user_id,
        name,
        attachments
      FROM
        aws_iam_user,
        jsonb_array_elements_text(attached_policy_arns) AS attachments
      WHERE
        split_part(attachments, '/', 2) = 'AdministratorAccess'
    )

    SELECT
      u.name AS "IAM User", -- Use u.name instead of u.arn
      'alarm' AS "Status",
      CASE
        WHEN au.user_id IS NULL THEN u.name || ' does not have administrator access.'
        WHEN au.user_id IS NOT NULL AND u.mfa_enabled THEN u.name || ' has MFA token enabled.'
        ELSE ' MFA token disabled.'
      END AS "Reason",
      u.region AS "Region",
      u.account_id AS "Account ID"
    FROM
      aws_iam_user AS u
      LEFT JOIN admin_users au ON u.user_id = au.user_id
    WHERE
      (au.user_id IS NOT NULL AND u.mfa_enabled = false) -- Filter only for users with MFA disabled
    ORDER BY
      u.name;

  EOQ
}

query "iam_role_cross_account_read_only_access_policy_table" {
  sql = <<-EOQ
    WITH read_only_access_roles AS (
      SELECT
        *
      FROM
        aws_iam_role,
        jsonb_array_elements_text(attached_policy_arns) AS a
      WHERE
        a = 'arn:aws:iam::aws:policy/ReadOnlyAccess'
    ),
    read_only_access_roles_with_cross_account_access AS (
      SELECT
        arn
      FROM
        read_only_access_roles,
        jsonb_array_elements(assume_role_policy_std -> 'Statement') AS stmt,
        jsonb_array_elements_text(stmt -> 'Principal' -> 'AWS') AS p
      WHERE
        stmt ->> 'Effect' = 'Allow'
        AND (
          p = '*'
          OR NOT (p LIKE '%' || account_id || '%')
        )
    )
    SELECT
      r.name AS "Role Name",
      'alarm' AS "Status",
      CASE
        WHEN ar.arn IS NULL THEN r.title || ' not associated with ReadOnlyAccess policy.'
        WHEN c.arn IS NOT NULL THEN r.title || ' associated with ReadOnlyAccess cross account access.'
        ELSE r.title || ' associated ReadOnlyAccess without cross account access.'
      END AS "Reason",
      r.account_id AS "Account ID"
    FROM
      aws_iam_role AS r
      LEFT JOIN read_only_access_roles AS ar ON r.arn = ar.arn
      LEFT JOIN read_only_access_roles_with_cross_account_access AS c ON c.arn = r.arn
    WHERE
      c.arn IS NOT NULL -- Filter only for roles with cross account access
    ORDER BY
      r.title;
  EOQ
}

query "iam_role_cross_account_administrator_access_policy_table" {
  sql = <<-EOQ
    WITH read_only_access_roles AS (
      SELECT
        *
      FROM
        aws_iam_role,
        jsonb_array_elements_text(attached_policy_arns) AS a
      WHERE
        a = 'arn:aws:iam::aws:policy/AdministratorAccess'
    ),
    read_only_access_roles_with_cross_account_access AS (
      SELECT
        arn
      FROM
        read_only_access_roles,
        jsonb_array_elements(assume_role_policy_std -> 'Statement') AS stmt,
        jsonb_array_elements_text(stmt -> 'Principal' -> 'AWS') AS p
      WHERE
        stmt ->> 'Effect' = 'Allow'
        AND (
          p = '*'
          OR NOT (p LIKE '%' || account_id || '%')
        )
    )
    SELECT
      r.name AS "Role Name",
      'alarm' AS "Status",
      CASE
        WHEN ar.arn IS NULL THEN r.title || ' not associated with AdministratorAccess policy.'
        WHEN c.arn IS NOT NULL THEN r.title || ' associated with AdministratorAccess cross account access.'
        ELSE r.title || ' associated AdministratorAccess without cross account access.'
      END AS "Reason",
      r.account_id AS "Account ID"
    FROM
      aws_iam_role AS r
      LEFT JOIN read_only_access_roles AS ar ON r.arn = ar.arn
      LEFT JOIN read_only_access_roles_with_cross_account_access AS c ON c.arn = r.arn
    WHERE
      c.arn IS NOT NULL -- Filter only for roles with cross account access
    ORDER BY
      r.title;
  EOQ
}

query "iam_account_password_policy_strong_table" {
  sql = <<-EOQ
    select
      'arn:' || a.partition || ':::' || a.account_id AS "account",
      case
        when minimum_password_length >= 14
        and password_reuse_prevention >= 5
        and require_lowercase_characters = 'true'
        and require_uppercase_characters = 'true'
        and require_numbers = 'true'
        and max_password_age <= 90 then 'ok'
        else 'alarm'
      end status,
      case
        when minimum_password_length is null then 'No password policy set.'
        when minimum_password_length >= 14
        and password_reuse_prevention >= 5
        and require_lowercase_characters = 'true'
        and require_uppercase_characters = 'true'
        and require_numbers = 'true'
        and max_password_age <= 90 then 'Strong password policies configured.'
        else 'Strong password policies not configured.'
      end reason,
      a.account_id AS "account id"
    from
      aws_account as a
      left join aws_iam_account_password_policy as pol on a.account_id = pol.account_id;
  EOQ
}

query "roles_that_might_allow_other_roles_users_to_bypass_assigned_iam_permissions" {
  sql = <<-EOQ
    select
      r.name,
      stmt
    from
      aws_iam_role as r,
      jsonb_array_elements(r.assume_role_policy_std -> 'Statement') as stmt,
      jsonb_array_elements_text(stmt -> 'Principal' -> 'AWS') as trust
    where
      trust = '*'
      or trust like 'arn:aws:iam::%:role/%'
  EOQ
}

query "iam_access_analyzer_enabled" {
  sql = <<-EOQ
    select
      'arn:' || r.partition || '::' || r.region || ':' || r.account_id as resource,
      case
        -- Skip any regions that are disabled in the account.
        when r.opt_in_status = 'not-opted-in' then 'skip'
        when aa.arn is not null then 'ok'
        else 'alarm'
      end as status,
      case
        when r.opt_in_status = 'not-opted-in' then r.region || ' region is disabled.'
        when aa.arn is not null then aa.name || ' enabled in ' || r.region || '.'
        else 'Access Analyzer not enabled in ' || r.region || '.'
      end as reason,
      r.region,
      r.account_id
    from
      aws_region as r
      left join aws_accessanalyzer_analyzer as aa on r.account_id = aa.account_id
      and r.region = aa.region;
  EOQ
}


