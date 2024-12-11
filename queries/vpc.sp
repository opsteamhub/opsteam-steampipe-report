
query "vpc_security_group_ssh_access" {
  sql = <<-EOQ
    SELECT
      sg.group_name AS "Security Group Name",
      sg.group_id AS "Security Group ID",
      sgr.type AS "Type",
      sgr.ip_protocol AS "Protocol",
      sgr.from_port AS "From Port",
      sgr.to_port AS "To Port",
      sgr.cidr_ipv4 AS "CIDR IP",
      sgr.region AS "Region"
    FROM
      aws_vpc_security_group sg
      INNER JOIN aws_vpc_security_group_rule sgr ON sg.group_id = sgr.group_id
    WHERE
      sgr.type = 'ingress'
      AND sgr.cidr_ipv4 = '0.0.0.0/0'
      AND sgr.ip_protocol = 'tcp'
      AND sgr.from_port = 22
      AND sgr.to_port = 22
      AND sg.group_name <> 'default'; -- Adiciona esta condição para excluir o group_name 'default'
    
  EOQ
}

query "vpc_security_group_rdp_access" {
  sql = <<-EOQ
    SELECT
      sg.group_name AS "Security Group Name",
      sg.group_id AS "Security Group ID",
      sgr.type AS "Type",
      sgr.ip_protocol AS "Protocol",
      sgr.from_port AS "From Port",
      sgr.to_port AS "To Port",
      sgr.cidr_ipv4 AS "CIDR IP",
      sgr.region AS "Region"
    FROM
      aws_vpc_security_group sg
      INNER JOIN aws_vpc_security_group_rule sgr ON sg.group_id = sgr.group_id
    WHERE
      sgr.type = 'ingress'
      AND sgr.cidr_ipv4 = '0.0.0.0/0'
      AND sgr.ip_protocol = 'tcp'
      AND sgr.from_port = 3389
      AND sgr.to_port = 3389
      AND sg.group_name <> 'default'; -- Adiciona esta condição para excluir o group_name 'default'

  EOQ
}

query "vpc_security_group_db_ports_access" {
  sql = <<-EOQ
    SELECT
      sg.group_name AS "Security Group Name",
      sg.group_id AS "Security Group ID",
      sgr.type AS "Type",
      sgr.ip_protocol AS "Protocol",
      sgr.from_port AS "From Port",
      sgr.to_port AS "To Port",
      sgr.cidr_ipv4 AS "CIDR IP",
      sgr.region AS "Region"
    FROM
      aws_vpc_security_group sg
      INNER JOIN aws_vpc_security_group_rule sgr ON sg.group_id = sgr.group_id
    WHERE
      sgr.type = 'ingress'
      AND sgr.cidr_ipv4 = '0.0.0.0/0'
      AND sgr.ip_protocol = 'tcp'
      AND (
        (sgr.from_port = 5432 AND sgr.to_port = 5432)
        OR (sgr.from_port = 3306 AND sgr.to_port = 3306)
        OR (sgr.from_port = 27017 AND sgr.to_port = 27017)
        OR (sgr.from_port = 9100 AND sgr.to_port = 9100)
        OR (sgr.from_port = 6379 AND sgr.to_port = 6379)
        OR (sgr.from_port = 11211 AND sgr.to_port = 11211)
      )
      AND sg.group_name <> 'default';
  EOQ
}

