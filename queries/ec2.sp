### EC2 ###

query "ec2_instance_public_access_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Publicly Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      aws_ec2_instance
    where
      public_ip_address is not null;
  EOQ
}

query "ec2_instance_public_access_table" {
  sql = <<-EOQ
    SELECT
      i.instance_id AS "Instance ID",
      i.tags ->> 'Name' AS "Name",
      'Public' AS "Public/Private",
      i.public_ip_address AS "Public IP Address",
      a.title AS "Account",
      i.account_id AS "Account ID",
      i.region AS "Region",
      i.arn AS "ARN"
    FROM
      aws_ec2_instance AS i,
      aws_account AS a
    WHERE
      i.account_id = a.account_id
      AND i.public_ip_address IS NOT NULL -- Add this condition to filter out private instances
    ORDER BY
      i.instance_id;

  EOQ
}

query "ec2_instance_count" {
  sql = <<-EOQ
    select count(*) as "Instances" from aws_ec2_instance
  EOQ
}

query "ec2_instances_should_not_use_older_generation_type_table" {
  sql = <<-EOQ
    SELECT
      DISTINCT ON (tags ->> 'Name') -- Select only one row for each unique instance name
        tags ->> 'Name' AS "Instance Name",
        CASE
          WHEN instance_type LIKE 't2.%'
               OR instance_type LIKE 'm3.%'
               OR instance_type LIKE 'm4.%' THEN 'alarm'
          ELSE 'ok'
        END AS "Status",
        instance_type AS "Reason", -- Include the instance_type as the reason
        region AS "Region",
        account_id AS "Account Id"
    FROM
      aws_ec2_instance
    WHERE
      (instance_type LIKE 't2.%'
       OR instance_type LIKE 'm3.%'
       OR instance_type LIKE 'm4.%') -- Add this condition to filter instances in alarm
    ORDER BY
      "Instance Name", -- Order by instance name to get the first row for each name
      account_id,      -- Add additional order by columns if necessary
      region;          -- Add additional order by columns if necessary

  EOQ
}


query "ec2_instances_without_graviton_processor_table" {
  sql = <<-EOQ
    SELECT
      DISTINCT ON (tags ->> 'Name') -- Select only one row for each unique instance name
        tags ->> 'Name' AS "Instance Name",
        CASE
          WHEN platform = 'windows' THEN 'skip'
          WHEN architecture = 'arm64' THEN 'ok'
          ELSE 'alarm'
        END AS "Status",
        CASE
          WHEN platform = 'windows' THEN title || ' is a windows type machine.'
          WHEN architecture = 'arm64' THEN title || ' is using Graviton processor.'
          ELSE  ' is not using Graviton processor.'
        END AS "Reason",
        region AS "Region",
        account_id AS "Account Id"
    FROM
      aws_ec2_instance
    WHERE
      (platform != 'windows' AND architecture != 'arm64') -- Add this condition to filter instances in alarm
    ORDER BY
      "Instance Name", -- Order by instance name to get the first row for each name
      account_id,      -- Add additional order by columns if necessary
      region;          -- Add additional order by columns if necessary

  EOQ
}

query "ebs_attached_volume_encryption_enabled" {
  sql = <<-EOQ
    select
      volume_id as "Volume ID",
      case
        when state != 'in-use' then 'skip'
        when encrypted then 'ok'
        else 'alarm'
      end as "Status",
      case
        when state != 'in-use' then ' not attached.'
        when encrypted then ' encrypted.'
        else ' not encrypted.'
      end as "Reason",
      region as "Region",
      account_id as "Account ID"
    from
      aws_ebs_volume
    where
      state = 'in-use' and not encrypted;
  EOQ
}

query "ebs_volume_unused" {
  sql = <<-EOQ
    SELECT
      volume_id AS "Volume ID",
      CASE
        WHEN state = 'in-use' THEN 'ok'
        ELSE 'alarm'
      END AS "Status",
      CASE
        WHEN state = 'in-use' THEN ' attached to EC2 instance.'
        ELSE  ' not attached to EC2 instance.'
      END AS "Reason",
      region as "Region",
      account_id as "Account ID"
    FROM
      aws_ebs_volume
    WHERE
      state != 'in-use';
  EOQ
}

query "ebs_gp2_volumes" {
  sql = <<-EOQ
  select
    volume_id as "Volume ID",
    case
      when volume_type = 'gp2' then 'alarm'
      else 'skip'
    end as "Status",
    volume_type as "Reason",
    region as "Region",
    account_id as "Account ID"
  from
    aws_ebs_volume
  where
    volume_type = 'gp2';
  EOQ
}