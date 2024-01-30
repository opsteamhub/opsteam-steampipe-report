### CloudFront ###

query "cloudfront_distribution_origin_access_identity_enabled_table" {
  sql = <<-EOQ
    SELECT
      id AS "Distribuitions",
      CASE
        WHEN o ->> 'DomainName' NOT LIKE '%s3.amazonaws.com' THEN 'skip'
        WHEN o ->> 'DomainName' LIKE '%s3.amazonaws.com' AND COALESCE(o -> 'S3OriginConfig' ->> 'OriginAccessIdentity', '') = '' THEN 'alarm'
        ELSE 'ok'
      END AS "Status",
      CASE
        WHEN o ->> 'DomainName' NOT LIKE '%s3.amazonaws.com' THEN ' origin type is not S3.'
        WHEN o ->> 'DomainName' LIKE '%s3.amazonaws.com' AND COALESCE(o -> 'S3OriginConfig' ->> 'OriginAccessIdentity', '') = '' THEN ' origin access identity not configured.'
        ELSE ' origin access identity configured.'
      END AS "Reason",
      region as "Region",
      account_id as "Account ID"
    FROM
      aws_cloudfront_distribution,
      jsonb_array_elements(origins) AS o
    WHERE
      o ->> 'DomainName' LIKE '%s3.amazonaws.com';
  EOQ
}  

query "cloudfront_distribution_non_s3_origins_encryption_in_transit_enabled_table" {
  sql = <<-EOQ
    WITH viewer_protocol_policy_value AS (
      SELECT DISTINCT arn
      FROM aws_cloudfront_distribution,
           jsonb_array_elements(
             CASE
               jsonb_typeof(cache_behaviors -> 'Items')
               WHEN 'array' THEN (cache_behaviors -> 'Items')
               ELSE NULL
             END
           ) AS cb
      WHERE cb ->> 'ViewerProtocolPolicy' = 'allow-all'
    ),
    origin_protocol_policy_value AS (
      SELECT DISTINCT
             arn,
             o -> 'CustomOriginConfig' ->> 'OriginProtocolPolicy' AS origin_protocol_policy
      FROM aws_cloudfront_distribution,
           jsonb_array_elements(origins) AS o
      WHERE (o -> 'CustomOriginConfig' ->> 'OriginProtocolPolicy' = 'http-only'
               OR (o -> 'CustomOriginConfig' ->> 'OriginProtocolPolicy' = 'match-viewer'
                   AND o -> 'S3OriginConfig' IS NULL))
    )
    SELECT b.id AS "Distributions",
           'alarm' AS "Status",
           ' origins traffic not encrypted in transit.' AS "Reason",
           b.region AS "Region",
           b.account_id AS "Account ID"
    FROM aws_cloudfront_distribution AS b
           LEFT JOIN origin_protocol_policy_value AS o ON b.arn = o.arn
    WHERE o.arn IS NOT NULL;    
  EOQ
}  

query "cloudfront_distribution_waf_enabled_table" {
  sql = <<-EOQ
    SELECT
      id AS "Distributions",
      'alarm' AS "Status",
      ' not associated with WAF.' AS "Reason",
      region AS "Region",
      account_id AS "Account ID"
    FROM
      aws_cloudfront_distribution
    WHERE
      web_acl_id = '';
  EOQ
}  