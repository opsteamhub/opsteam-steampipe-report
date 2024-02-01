### RDS ###

query "rds_db_cluster_encryption_table" {
  sql = <<-EOQ
    select
      c.db_cluster_identifier as "DB Cluster Identifier",
      case when c.storage_encrypted then 'Enabled' else null end as "Encryption",
      c.kms_key_id as "KMS Key ID",
      a.title as "Account",
      c.account_id as "Account ID",
      c.region as "Region",
      c.arn as "ARN"
    from
      aws_rds_db_cluster as c,
      aws_account as a
    where
      c.account_id = a.account_id
    order by
      c.db_cluster_identifier;
  EOQ
}

query "rds_db_cluster_count" {
  sql = <<-EOQ
    select count(*) as "DB Clusters" from aws_rds_db_cluster;
  EOQ
}

query "rds_db_cluster_unencrypted_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unencrypted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      aws_rds_db_cluster
    where
      not storage_encrypted;
  EOQ
}

query "rds_db_instance_encryption_table" {
  sql = <<-EOQ
    select
      i.db_instance_identifier as "DB Instance Identifier",
      case when i.storage_encrypted then 'Enabled' else null end as "Encryption",
      i.kms_key_id as "KMS Key ID",
      a.title as "Account",
      i.account_id as "Account ID",
      i.region as "Region",
      i.arn as "ARN"
    from
      aws_rds_db_instance as i,
      aws_account as a
    where
      i.account_id = a.account_id
    order by
      i.db_instance_identifier;
  EOQ
}

query "rds_db_instance_unencrypted_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unencrypted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      aws_rds_db_instance
    where
      not storage_encrypted;
  EOQ
}

query "rds_db_instance_count" {
  sql = <<-EOQ
    select count(*) as "RDS DB Instances" from aws_rds_db_instance
  EOQ
}

query "rds_db_instance_public_access_table" {
  sql = <<-EOQ
    select
      i.db_instance_identifier as "DB Instance Identifier",
      case
        when i.publicly_accessible then 'Public' else 'Private' end as "Public/Private",
      i.status as "Status",
      a.title as "Account",
      i.account_id as "Account ID",
      i.region as "Region",
      i.arn as "ARN"
    from
      aws_rds_db_instance as i,
      aws_account as a
    where
      i.account_id = a.account_id
    order by
      i.db_instance_identifier;
  EOQ
}

query "rds_db_instance_public_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Publicly Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      aws_rds_db_instance
    where
      publicly_accessible;
  EOQ
}

query "rds_db_instance_withou_graviton_processor" {
  sql = <<-EOQ
    select
      arn as resource,
      case
        when class like 'db.%g%.%' then 'ok'
        else 'alarm'
      end as status,
      case
        when class like 'db.%g%.%' then title || ' is using Graviton processor.'
        else title || ' is not using Graviton processor.'
      end as reason,
      region,
      account_id
    from
      aws_rds_db_instance;
  EOQ
}