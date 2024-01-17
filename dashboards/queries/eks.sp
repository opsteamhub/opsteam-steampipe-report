### EKS ###

query "eks_cluster_with_latest_kubernetes_version_table" {
  sql = <<-EOQ
    select
      name as "Cluster",
      case
        -- eks:oldestVersionSupported (Current oldest supported version is 1.23)
        when (version) :: decimal >= 1.23 then 'ok'
        else 'alarm'
      end as "Status",
      case
        when (version) :: decimal >= 1.23 then ' runs on a supported kubernetes version.'
        else ' does not run on a supported kubernetes version.'
      end as "Reason",
      region as "Region",
      account_id as "Account ID"
    from
      aws_eks_cluster;
  EOQ
}

query "eks_cluster_endpoints_should_prohibit_public_table" {
  sql = <<-EOQ
    select
      name as "Cluster",
      case
        when resources_vpc_config ->> 'EndpointPrivateAccess' = 'true'
        and resources_vpc_config ->> 'EndpointPublicAccess' = 'false' then 'ok'
        when resources_vpc_config ->> 'EndpointPublicAccess' = 'true'
        and resources_vpc_config -> 'PublicAccessCidrs' @> '["0.0.0.0/0"]' then 'alarm'
        else 'ok'
      end as "Status",
      case
        when resources_vpc_config ->> 'EndpointPrivateAccess' = 'true'
        and resources_vpc_config ->> 'EndpointPublicAccess' = 'false' then ' endpoint access is private.'
        when resources_vpc_config ->> 'EndpointPublicAccess' = 'true'
        and resources_vpc_config -> 'PublicAccessCidrs' @> '["0.0.0.0/0"]' then ' endpoint access is public.'
        else ' endpoint public access is restricted.'
      end as "Reason",
      region as "Region",
      account_id as "Account ID"
    from
      aws_eks_cluster;
  EOQ
}

query "eks_cluster_secrets_encrypted_table" {
  sql = <<-EOQ
    with eks_secrets_encrypted as (
      select
        distinct arn as arn
      from
        aws_eks_cluster,
        jsonb_array_elements(encryption_config) as e
      where
        e -> 'Resources' @> '["secrets"]'
    )
    select
      a.name as "Cluster",
      case
        when encryption_config is null then 'alarm'
        when b.arn is not null then 'ok'
        else 'alarm'
      end as "Status",
      case
        when encryption_config is null then  ' encryption not enabled.'
        when b.arn is not null then  ' encrypted with EKS secrets.'
        else  ' not encrypted with EKS secrets.'
      end as "Reason",
      region as "Region",
      account_id as "Account ID"
    from
      aws_eks_cluster as a
      left join eks_secrets_encrypted as b on a.arn = b.arn;
  EOQ
}

query "eks_cluster_control_plane_audit_logging_enabled_table" {
  sql = <<-EOQ
    with control_panel_audit_logging as (
      select
        distinct arn,
        log -> 'Types' as log_type
      from
        aws_eks_cluster,
        jsonb_array_elements(logging -> 'ClusterLogging') as log
      where
        log ->> 'Enabled' = 'true'
        and (log -> 'Types') @> '["api", "audit", "authenticator", "controllerManager", "scheduler"]'
    )
    select
      c.name as "Cluster",
      case
        when l.arn is not null then 'ok'
        else 'alarm'
      end as "Status",
      case
        when l.arn is not null then ' control plane audit logging enabled for all log types.'
        else case
          when logging -> 'ClusterLogging' @> '[{"Enabled": true}]' then ' control plane audit logging not enabled for all log types.'
          else  ' control plane audit logging not enabled.'
        end
      end as "Reason",
      c.region as "Region",
      c.account_id as "Account ID"
    from
      aws_eks_cluster as c
      left join control_panel_audit_logging as l on l.arn = c.arn;
  EOQ
}