### LAMBDA ###

query "lambda_function_variables_no_sensitive_data" {
  sql = <<-EOQ
    with function_vaiable_with_sensitive_data as (
      select
        distinct arn,
        name
      from
        aws_lambda_function
        join jsonb_each_text(environment_variables) d on true
      where
        d.key ilike any (array [ '%pass%', '%secret%', '%token%', '%key%' ])
        or d.key ~ '(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]'
        or d.value ilike any (array [ '%pass%', '%secret%', '%token%', '%key%' ])
        or d.value ~ '(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]'
    )
    select
      f.arn as resource,
      'alarm' as status,
      f.title || ' has potential sensitive data.' as reason,
      region,
      account_id
    from
      aws_lambda_function as f
      join function_vaiable_with_sensitive_data b on f.arn = b.arn
    where
      b.arn is not null
    order by
      f.title;
  EOQ
}

query "lambda_function_cloudtrail_logging_enabled" {
  sql = <<-EOQ
    with function_logging_cloudtrails as (
      select
        distinct replace(replace(v :: text, '"', ''), '/', '') as lambda_arn,
        d ->> 'Type' as type
      from
        aws_cloudtrail_trail,
        jsonb_array_elements(event_selectors) e,
        jsonb_array_elements(e -> 'DataResources') as d,
        jsonb_array_elements(d -> 'Values') v
      where
        d ->> 'Type' = 'AWS::Lambda::Function'
        and replace(replace(v :: text, '"', ''), '/', '') <> 'arn:aws:lambda'
    ),
    function_logging_region as (
      select
        region as cloudtrail_region,
        replace(replace(v :: text, '"', ''), '/', '') as lambda_arn
      from
        aws_cloudtrail_trail,
        jsonb_array_elements(event_selectors) e,
        jsonb_array_elements(e -> 'DataResources') as d,
        jsonb_array_elements(d -> 'Values') v
      where
        d ->> 'Type' = 'AWS::Lambda::Function'
        and replace(replace(v :: text, '"', ''), '/', '') = 'arn:aws:lambda'
      group by
        region,
        lambda_arn
    ),
    function_logging_region_advance_es as (
      select
        region as cloudtrail_region
      from
        aws_cloudtrail_trail,
        jsonb_array_elements(advanced_event_selectors) a,
        jsonb_array_elements(a -> 'FieldSelectors') as f,
        jsonb_array_elements_text(f -> 'Equals') e
      where
        e = 'AWS::Lambda::Function'
        and f ->> 'Field' != 'eventCategory'
      group by
        region
    )
    select
      distinct l.arn as resource,
      case
        when (l.arn = c.lambda_arn)
        or (
          r.lambda_arn = 'arn:aws:lambda'
          and r.cloudtrail_region = l.region
        )
        or a.cloudtrail_region = l.region then 'ok'
        else 'alarm'
      end as status,
      case
        when (l.arn = c.lambda_arn)
        or (
          r.lambda_arn = 'arn:aws:s3'
          and r.cloudtrail_region = l.region
        )
        or a.cloudtrail_region = l.region then l.name || ' logging enabled.'
        else l.name || ' logging not enabled.'
      end as reason,
      l.region,
      l.account_id
    from
      aws_lambda_function as l
      left join function_logging_cloudtrails as c on l.arn = c.lambda_arn
      left join function_logging_region as r on r.cloudtrail_region = l.region
      left join function_logging_region_advance_es as a on a.cloudtrail_region = l.region;
  
  EOQ
}

query "lambda_function_use_latest_runtime" {
  sql = <<-EOQ
    select
      arn as resource,
      case
        when package_type <> 'Zip' then 'skip'
        when runtime in (
          'nodejs18.x',
          'nodejs16.x',
          'nodejs14.x',
          'python3.10',
          'python3.9',
          'python3.8',
          'python3.7',
          'ruby3.2',
          'ruby2.7',
          'java17',
          'java11',
          'java8',
          'java8.al2',
          'go1.x',
          'dotnet7',
          'dotnet6'
        ) then 'ok'
        else 'alarm'
      end as status,
      case
        when package_type <> 'Zip' then title || ' package type is ' || package_type || '.'
        when runtime in (
          'nodejs18.x',
          'nodejs16.x',
          'nodejs14.x',
          'python3.10',
          'python3.9',
          'python3.8',
          'python3.7',
          'ruby3.2',
          'ruby2.7',
          'java17',
          'java11',
          'java8',
          'java8.al2',
          'go1.x',
          'dotnet7',
          'dotnet6'
        ) then title || ' uses latest runtime - ' || runtime || '.'
        else title || ' uses ' || runtime || ' which is not the latest version.'
      end as reason,
      region,
      account_id
    from
      aws_lambda_function
    where
      (package_type = 'Zip' and runtime not in (
        'nodejs18.x',
        'nodejs16.x',
        'nodejs14.x',
        'python3.10',
        'python3.9',
        'python3.8',
        'python3.7',
        'ruby3.2',
        'ruby2.7',
        'java17',
        'java11',
        'java8',
        'java8.al2',
        'go1.x',
        'dotnet7',
        'dotnet6'
      ));
    
  EOQ
}
