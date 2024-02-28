### ELB ###

query "elb_tls_listener_protocol_version" {
  sql = <<-EOQ
    select
      load_balancer_arn as resource,
      'alarm' as status,
      case
        when protocol <> 'HTTPS' then title || ' uses protocol ' || protocol || '.'
        when ssl_policy like any (array [ 'Protocol-SSLv3', 'Protocol-TLSv1' ]) then title || ' uses insecure SSL or TLS cipher.'
        else title || ' uses secure SSL or TLS cipher.'
      end as reason,
      region,
      account_id
    from
      aws_ec2_load_balancer_listener
    where
      protocol = 'HTTPS'
      and ssl_policy like any(array [ 'Protocol-SSLv3', 'Protocol-TLSv1' ]);

  EOQ
}
