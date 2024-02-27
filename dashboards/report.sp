dashboard "report" {

  title         = "Ops Team Security Assessment Report"

  tags = merge(local.aws_common_tags, {
    type     = "Report"
    category = "Compliance"
  })


  container {
    container {
    width = 9
      image {
        src = "https://ops.team/wp-content/uploads/2023/06/logo2-1.png"
        alt = "Ops Team Logo"
        width = 3
      }      
    }    
  }

  container {

    title = "IAM"

    card {
      query = query.account_count
      width = 2
    }

  }

  table {
    column "ARN" {
      display = "none"
    }

    query = query.account_table
  }

  table {
    title = "AWS account should be part of AWS Organizations"
    column "ARN" {
      display = "none"
    }
    column "Account ID" {
      display = "none"
    }    

    query = query.account_part_of_organizations
  }


  container {

    title = "Root access report"

    card {
      width = 3
      query = query.iam_root_access_keys_count
    }

    card {
      width = 3
      query = query.iam_accounts_without_root_mfa
    }

  }

  table {

    column "Account ID" {
      display = "none"
    }

    query = query.iam_root_access_keys_table
  }

  text {
    #width = 1
    value = <<-EOM
      #### Recomendações:

      É altamente recomendável não criar pares de chaves de acesso para o usuário raiz. Como apenas algumas tarefas exigem o usuário raiz e elas
      normalmente são executadas com pouca frequência, recomendamos entrar no AWS Management Console para realizar as tarefas de usuário raiz. Antes de
      criar chaves de acesso, avalie as alternativas às chaves de acesso de longo prazo.

      A utilização de MFA (Autenticação de Fator Duplo) para o usuário raiz (root) na AWS é uma prática fundamental de segurança. Aqui estão algumas recomendações específicas:

      **Ative o MFA:**
      
      - Ative a autenticação de fator duplo para o usuário raiz da AWS. Isso adiciona uma camada adicional de segurança, exigindo um segundo fator (além da senha) para autenticação.
      
      **Use Dispositivos Móveis ou Tokens de Hardware:**
      
      - Prefira a autenticação MFA usando aplicativos autenticadores em dispositivos móveis (como Google Authenticator ou Authy) ou tokens de hardware (como YubiKey). Esses métodos são mais seguros do que receber códigos MFA por e-mail ou SMS.
      
      **Armazene Códigos de Recuperação de Forma Segura:**
      
      - Ao configurar o MFA, armazene os códigos de recuperação de forma segura. Eles são essenciais para acessar a conta caso o dispositivo MFA seja perdido ou inacessível.
      
      **Evite MFA por E-mail ou SMS:**
      
      - Evite métodos de MFA baseados em e-mail ou SMS, pois esses podem ser mais vulneráveis a ataques de phishing ou SIM swap.
      
      **Implemente Políticas de Senha Fortes:**
      
      - Além do MFA, implemente políticas de senha fortes para o usuário raiz. Isso ajuda a proteger a conta mesmo em situações em que o MFA não está disponível.
      
      **Monitoramento e Alertas:**
      
      - Configure monitoramento e alertas para atividades suspeitas ou tentativas de login não autorizadas na conta raiz.
      
      **Revisão Periódica:**
      
      - Realize revisões periódicas das configurações de segurança da conta, incluindo o MFA, para garantir que estejam alinhadas com as melhores práticas de segurança da AWS.
      
      **Separação de Funções:**
      
      - Evite usar a conta raiz para atividades do dia a dia. Crie usuários IAM separados com as permissões necessárias e pratique o princípio de menor privilégio.
      
      **Lembrando que a AWS recomenda fortemente o uso de MFA para o usuário raiz e fornece ferramentas e recursos para facilitar a implementação dessa prática de segurança.**

    EOM
  }

  container {
    title = "IAM password policies for users should have strong configurations"
    table {
      #column "Account ID" {
      #  display = "none"
      #}

      column "User ARN" {
        display = "none"
      }

      query = query.iam_account_password_policy_strong_table
    }

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:    
        Recomenda-se configurar políticas de senha robustas no AWS Identity and Access Management (IAM) para usuários.   
        Adote práticas de segurança como requisitos de comprimento mínimo, uso de caracteres especiais, números e letras, além de exigir atualizações periódicas de senha.   
        Implementar políticas rigorosas fortalece a segurança das credenciais IAM, reduzindo o risco de comprometimento de contas e contribuindo para uma postura geral mais segura no gerenciamento de identidades e acessos na AWS.

      EOM
    }
  } 

  container {

    title         = "Access Key Age Report" 

    card {
      width = 2
      query = query.iam_access_count
    }

    card {
      type  = "info"
      width = 2
      query = query.iam_access_key_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.iam_access_key_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.iam_access_key_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.iam_access_key_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.iam_access_key_1_year_count
    }

  }

  table {
    column "Account ID" {
      display = "none"
    }

    column "User ARN" {
      display = "none"
    }

    query = query.iam_access_key_age_table
  }

  text {
    #width = 1
    value = <<-EOM
      #### Recomendações:

      Recomenda-se realizar a rotação regular de chaves na AWS para aumentar a segurança e reduzir o risco de comprometimento de credenciais.  
      Implemente boas práticas, como a rotação regular de chaves, para fortalecer a segurança da conta AWS, reduzir o risco de acesso não autorizado e garantir o cumprimento de políticas de segurança.    
      Considere a automação desse processo para simplificar a gestão de chaves e manter a conformidade ao longo do tempo.

    EOM
  }
  
  container {
    title = "Role with AdministratorAccess policy attached"
    table {
      #column "Account ID" {
      #  display = "none"
      #}

      column "User ARN" {
        display = "none"
      }

      query = query.iam_role_no_administrator_access_policy_attached_table
    }

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:   
        A AWS fornece várias recomendações de segurança para roles com a política **"AdministratorAccess"** anexada, que concede permissões administrativas completas.   
        **Aqui estão algumas práticas recomendadas:**
        
        **Princípio do Menor Privilégio:**   
        Evite atribuir permissões administrativas a roles ou usuários, a menos que seja absolutamente necessário.    
        Atribua apenas as permissões mínimas necessárias para realizar as tarefas específicas.   
        **Auditoria e Monitoramento:**   
        Ative o AWS CloudTrail para auditar todas as ações realizadas na sua conta.   
        Configure alertas para detectar atividades suspeitas ou não autorizadas.   
        **MFA (Multi-Factor Authentication):**   
        Exija o uso de MFA para todas as contas que possuam a política "AdministratorAccess".
      EOM
    }
  } 

  container {
    title = "IAM user with AdministratorAccess policy attached without MFA enabled"
    table {
      #column "Account ID" {
      #  display = "none"
      #}

      column "User ARN" {
        display = "none"
      }

      query = query.iam_user_with_administrator_access_mfa_enabled_table
    }

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:

        Quando um usuário IAM na AWS tem a política **"AdministratorAccess"** anexada sem a autenticação de **Fator Multi-Fator (MFA)** ativada, pode representar um risco significativo de segurança.   
        **Aqui estão algumas recomendações para melhorar a segurança nessas situações:** 

        **Ativação de MFA:**   
        - **Requisitar Ativação:** Exija que todos os usuários com a política **"AdministratorAccess"** ativem o **MFA** imediatamente.   
        - **Política de Força:** Implemente uma política que negue o acesso a usuários com a política **"AdministratorAccess"** anexada, a menos que o **MFA** esteja ativado.    
        
        **Política do Menor Privilégio:**    
        - **Revise Permissões:** Avalie cuidadosamente as permissões concedidas pela política **"AdministratorAccess**.   
            Reduza as permissões para o mínimo necessário para a execução das funções do usuário.

      EOM
    }
  }   
  
  container {
    title = "IAM role cross account with ReadOnlyAccess policy attached"
    table {
      #column "Account ID" {
      #  display = "none"
      #}

      column "User ARN" {
        display = "none"
      }

      query = query.iam_role_cross_account_read_only_access_policy_table
    }

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Quando necessário o uso de funções IAM em contas diferentes, recomendamos criar funções com políticas restritas, como a política ReadOnlyAccess, para garantir acesso somente de leitura entre contas.  
        Isso ajuda a limitar a exposição e os riscos de segurança associados às permissões concedidas.
      EOM
    }
  } 

  container {
    title = "IAM role cross account with AdministratorAccess policy attached"
    table {
      #column "Account ID" {
      #  display = "none"
      #}

      column "User ARN" {
        display = "none"
      }

      query = query.iam_role_cross_account_administrator_access_policy_table
    }

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:

        Recomenda-se realizar a rotação regular de chaves na AWS para aumentar a segurança e reduzir o risco de comprometimento de credenciais.  
        Implemente boas práticas, como a rotação regular de chaves, para fortalecer a segurança da conta AWS, reduzir o risco de acesso não autorizado e garantir o cumprimento de políticas de segurança.    
        Considere a automação desse processo para simplificar a gestão de chaves e manter a conformidade ao longo do tempo.

      EOM
    }
  }

  container {
    title = "List the roles that might allow other roles users to bypass their assigned IAM permissions"
    table {
      #column "Account ID" {
      #  display = "none"
      #}

      column "User ARN" {
        display = "none"
      }

      query = query.roles_that_might_allow_other_roles_users_to_bypass_assigned_iam_permissions
    }

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:

        Recomenda-se Determinar as áreas nas quais algumas funções podem permitir que outros usuários contornem as permissões do IAM atribuídas. 
		    Essa consulta é útil para identificar possíveis riscos de segurança e garantir que as permissões sejam atribuídas corretamente em seu ambiente AWS.

      EOM
    }
  }   
  
    container {
    title = "IAM Access Analyzer Enabled"
    table {
      #column "Account ID" {
      #  display = "none"
      #}

      column "User ARN" {
        display = "none"
      }

      query = query.iam_access_analyzer_enabled
    }

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:

        Recomenda-se aplicar sempre o princípio de privilégio mínimo com análise de acesso e validação de políticas para definir, verificar e refinar permissões em seu ambiente AWS.
		    Analisar e remover acessos externos e não utilizados nas contas da AWS de forma centralizada e com monitoramento contínuo

      EOM
    }
  }

  container {
    title = "S3"
    
    table {
      title = "Buckets public read access"
      column "ARN" {
        display = "none"
      }
      query = query.s3_bucket_public_read_access_table
    }
  

  container {    
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Realizar uma análise minuciosa de cada bucket S3 é fundamental para determinar a real necessidade de mantê-lo público.       
        Caso seja imprescindível, recomenda-se restringir o acesso exclusivamente ao CloudFront.    
        Essa abordagem visa assegurar a segurança do bucket, fornecendo uma camada adicional de controle e autenticação por meio do Amazon CloudFront.
      EOM
      } 
    }
    
    container {
      
    table {
      title = "Buckets public write access"
      column "ARN" {
        display = "none"
      }
      query = query.s3_bucket_public_write_access_table
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Realizar uma análise minuciosa de cada bucket S3 é fundamental para determinar a real necessidade de mantê-lo público.       
        Caso seja imprescindível, recomenda-se restringir o acesso exclusivamente ao CloudFront.    
        Essa abordagem visa assegurar a segurança do bucket, fornecendo uma camada adicional de controle e autenticação por meio do Amazon CloudFront.
      EOM
      }
    }
    container {

    chart {
      title = "Buckets block public access" 
      query = query.s3_bucket_public_access_blocked
      type  = "donut"
      width = 3
    
      series "count" {
        point "blocked" {
          color = "ok"
        }
        point "not blocked" {
          color = "alert"
        }
      }
    }
    chart {
      title = "Default Encryption Status"
      query = query.s3_bucket_by_default_encryption_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }
    chart {
      title = "Logging Status"
      query = query.s3_bucket_logging_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Versioning Status"
      query = query.s3_bucket_versioning_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }        

    table {
      title = "Buckets block public access" 
      column "ARN" {
        display = "none"
      }
      query = query.s3_public_access_block_bucket_table
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        A recomendação da AWS para a configuração do **"Public Access Block"** em buckets do Amazon S3 é uma prática de segurança essencial para evitar inadvertidamente a exposição pública de dados.    
        O **"Block Public Access"** fornece uma camada adicional de proteção, impedindo que buckets tenham permissões públicas acidentais.
        **Aqui estão algumas diretrizes e práticas recomendadas:**
        Ative o **"Public Access Block"**:
        Certifique-se de ativar o **"Public Access Block"** em seus buckets do Amazon S3 para evitar que as políticas permitam o acesso público não intencional.
      EOM
      }      
    }      
  }

  container {
    container {
      title = "DynamoDB"
      container {
      title = "DynamoDB table encryption report"
        card {
          query = query.dynamodb_table_count
          width = 3
          type = "info"
        }
        card {
          query = query.dynamodb_table_default_encryption
          width = 3
          type = "info"
        }
        card {
          query = query.dynamodb_table_aws_managed_key_encryption
          width = 3
          type = "info"
        }
        card {
          query = query.dynamodb_table_customer_managed_key_encryption
          width = 3
          type = "info"
        }
      }  
    }
    container{
      table {
        #column "Account ID" {
        #  display = "none"
        #}
        column "ARN" {
          display = "none"
        }
        query = query.dynamodb_table_encryption_table
      }
      text {
        #width = 1
        value = <<-EOM
          #### Recomendações:
          Realizar uma análise minuciosa de cada bucket S3 é fundamental para determinar a real necessidade de mantê-lo público.       
          Caso seja imprescindível, recomenda-se restringir o acesso exclusivamente ao CloudFront.    
          Essa abordagem visa assegurar a segurança do bucket, fornecendo uma camada adicional de controle e autenticação por meio do Amazon CloudFront.
        EOM
        }    
    }  
    container {
      table {
        title = "DynamodDB table point in time recovery enabled"
        #column "Account ID" {
        #  display = "none"
        #}
        column "ARN" {
          display = "none"
        }
        query = query.dynamodb_table_point_in_time_recovery_enabled
      }  
      text {
        #width = 1
        value = <<-EOM
          #### Recomendações:
          Realizar uma análise minuciosa de cada bucket S3 é fundamental para determinar a real necessidade de mantê-lo público.       
          Caso seja imprescindível, recomenda-se restringir o acesso exclusivamente ao CloudFront.    
          Essa abordagem visa assegurar a segurança do bucket, fornecendo uma camada adicional de controle e autenticação por meio do Amazon CloudFront.
        EOM
      }    
    }

    container {
      table {
        title = "DynamoDB tables should be in a backup plan"
        #column "Account ID" {
        #  display = "none"
        #}
        column "ARN" {
          display = "none"
        }
        query = query.dynamodb_table_in_backup_plan_table
      }  
      text {
        #width = 1
        value = <<-EOM
          #### Recomendações:
          Realizar uma análise minuciosa de cada bucket S3 é fundamental para determinar a real necessidade de mantê-lo público.       
          Caso seja imprescindível, recomenda-se restringir o acesso exclusivamente ao CloudFront.    
          Essa abordagem visa assegurar a segurança do bucket, fornecendo uma camada adicional de controle e autenticação por meio do Amazon CloudFront.
        EOM
      }    
    }

  }

  container {
    title = "EC2"
    container {
      title = "EC2 instance public access report"
      card {
        query = query.ec2_instance_count
        width = 3
      }

      card {
        query = query.ec2_instance_public_access_count
        width = 3
      }

    }

    table {
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.ec2_instance_public_access_table
    }  

      text {
        #width = 1
        value = <<-EOM
          #### Recomendações:

          Recomenda-se utilizar IPs privados nas instâncias EC2 e acessá-las via VPN ou VPC Endpoint Instance Connect para reforçar a segurança da comunicação.   
          Quando necessário acesso externo, opte pelo uso de Load Balancers para distribuir o tráfego de maneira segura, garantindo alta disponibilidade e gerenciamento eficiente.    
          Essa abordagem reduz a exposição direta de IPs públicos, fortalecendo a postura de segurança da infraestrutura na nuvem AWS.
        EOM
        }

    table {
      title = "List EC2 instances having termination protection safety feature enabled"
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.list_ec2_instances_having_termination_protection_safety_feature_enabled
    }  

      text {
        #width = 1
        value = <<-EOM
          #### Recomendações:

          Recomenda-se sempre manter habilitado esta funcionalidade em todas as EC2. Isto evita que qualquer EC2 possa ser finalizada/encerrada acidentalmente. Evitando assim
		      problemas futuros em disponibilidade do serviço, garantindo sua estabilidade.
 
        EOM
        } 		

    table {
      title = "EC2 instances should not use older generation t2, m3, and m4 instance types"
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.ec2_instances_should_not_use_older_generation_type_table
    }  

      text {
        #width = 1
        value = <<-EOM
          #### Recomendações:

          Recomenda-se evitar o uso de instâncias mais antigas, como **t2, m3 e m4**, para instâncias EC2.    
          Opte por instâncias mais recentes e otimizadas para obter melhor desempenho, segurança e benefícios de custo.   
           Atualizar para gerações mais recentes de instâncias EC2 proporcionará suporte a recursos aprimorados, maior eficiência e melhorias contínuas de segurança e desempenho fornecidas pela AWS.
        EOM
        }          

    table {
      title = "EC2 instances without graviton processor should be reviewed"
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.ec2_instances_without_graviton_processor_table
    }  

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Recomenda-se revisar instâncias EC2 que não possuem processadores **Graviton**.   
        Avaliar e considerar a migração para instâncias **Graviton** pode resultar em benefícios significativos de desempenho e eficiência de custos.   
        Os processadores **Graviton**, baseados na arquitetura ARM, oferecem melhorias de desempenho e otimizações para cargas de trabalho específicas, proporcionando uma alternativa eficaz e econômica para instâncias tradicionais x86.
      EOM
    }  
    table {
      title = "Attached EBS volumes should have encryption enabled"
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.ebs_attached_volume_encryption_enabled
    }  

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:

        Para garantir a segurança dos dados sensíveis em repouso, é altamente recomendado habilitar a criptografia para os volumes do AWS Elastic Block Store (AWS EBS) em sua conta AWS.    
        Essa prática adiciona uma camada adicional de proteção, fortalecendo a segurança dos dados armazenados em seus volumes EBS na nuvem.
      EOM
    }     
    table {
      title = "EBS volumes should be attached to EC2 instances"
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.ebs_volume_unused
    }  

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Certifique-se de verificar periodicamente se os volumes EBS estão devidamente anexados a instâncias do EC2.   
        Isso ajuda a garantir que os recursos de armazenamento estejam sendo utilizados conforme o planejado e evita volumes não utilizados que podem gerar custos desnecessários.    
        Considere automatizar esse processo por meio de scripts ou ferramentas de monitoramento para manter a conformidade contínua.
      EOM
    }  
    table {
      title = "Still using gp2 EBS volumes? Should use gp3 instead."
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.ebs_gp2_volumes
    }  

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Considere migrar volumes EBS do tipo 'gp2' para 'gp3', pois os volumes 'gp3' oferecem melhor desempenho a um custo mais baixo.    
        Antes de fazer a migração, avalie suas necessidades de desempenho e custo para garantir que 'gp3' atenda aos requisitos da sua carga de trabalho.   
        Lembre-se de testar a migração em um ambiente controlado para validar o desempenho antes de aplicar em produção.
      EOM
    }    
    table {
      title = "EC2 instances should be protected by backup plan"
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.ec2_instance_protected_by_backup_plan
    }  

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Considere migrar volumes EBS do tipo 'gp2' para 'gp3', pois os volumes 'gp3' oferecem melhor desempenho a um custo mais baixo.    
        Antes de fazer a migração, avalie suas necessidades de desempenho e custo para garantir que 'gp3' atenda aos requisitos da sua carga de trabalho.   
        Lembre-se de testar a migração em um ambiente controlado para validar o desempenho antes de aplicar em produção.
      EOM
    } 
    table {
      title = "Find instances which have default security group attached"
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.find_instances_which_have_default_security_group_attached
    }  

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:

        Recomenda-se sempre analisar os segmentos que possuem o grupo de segurança padrão anexado a eles para identificar possíveis riscos de segurança. 
		    Isto é útil para manter práticas de segurança ideais e garantir que as instâncias não utilizem configurações padrão, que podem ser mais vulneráveis.
      EOM
    } 
    table {
      title = "List instances with secrets in user data"
      column "Account ID" {
        display = "none"
      }

      column "ARN" {
        display = "none"
      }

      query = query.list_instances_with_secrets_in_user_data
    }  

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Recomenda-se sempre analisar as instâncias que podem conter informações confidenciais nos dados do usuário. 
		    Isto é benéfico para identificar potenciais riscos de segurança e garantir a conformidade com a privacidade dos dados.
      EOM
    }    

  }  

  container {
    title = "RDS"
    container {
      
      container {
        title = "RDS DB cluster encryption report"
        card {
          query = query.rds_db_cluster_count
          width = 3
        }

        card {
          query = query.rds_db_cluster_unencrypted_count
          width = 3
        }

        table {
          column "Account ID" {
            display = "none"
          }

          column "ARN" {
            display = "none"
          }

          query = query.rds_db_cluster_encryption_table
        }
      }
    }
    container {
      title = "RDS DB instance encryption report"
      card {
        query = query.rds_db_instance_count
        width = 3
      }
  
      card {
        query = query.rds_db_instance_unencrypted_count
        width = 3
      }
  
    }
  
    table {
    
      column "Account ID" {
        display = "none"
      }
  
      column "ARN" {
        display = "none"
      }

      query = query.rds_db_instance_encryption_table
      
    }

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        
        Recomenda-se gerar e revisar periodicamente o relatório de criptografia de instâncias de banco de dados (DB Instances) na AWS RDS.    
        Certifique-se de que todas as instâncias de banco de dados estão configuradas para usar a criptografia, o que é fundamental para proteger dados sensíveis e garantir conformidade com requisitos de segurança.   
        Adicionalmente, avalie a implementação de boas práticas de gerenciamento de chaves, como a rotação regular e o controle de acesso adequado às chaves de criptografia utilizadas nas instâncias do RDS.   
        Isso contribuirá para uma postura de segurança robusta em ambientes de banco de dados na nuvem AWS.
      EOM
    }

    container { 
      title = "RDS DB Instance Public Access Report"
      card {       
        query = query.rds_db_instance_count
        width = 3
      }

      card {
        query = query.rds_db_instance_public_count
        width = 3
      }

      table {
      
        column "Account ID" {
          display = "none"
        }

        column "ARN" {
          display = "none"
        }

        query = query.rds_db_instance_public_access_table
      }
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        A AWS recomenda fortemente minimizar ou evitar o uso de instâncias de banco de dados RDS públicas devido a razões de segurança.   
        Configurar uma instância de banco de dados RDS como pública significa que ela pode ser acessada pela Internet, o que aumenta o risco de exposição a ameaças e ataques.

        **Utilize Instâncias de Banco de Dados Privadas:**   
        Configure suas instâncias de banco de dados RDS para serem privadas, o que significa que elas não têm acesso direto pela Internet.
        
        **Use Redes Virtuais Privadas (VPNs) ou AWS Direct Connect:**   
        Se você precisa acessar suas instâncias de banco de dados a partir de locais remotos, considere o uso de VPNs ou AWS Direct Connect para estabelecer conexões seguras.
        
        **Use Grupos de Segurança para Restringir Acesso:**   
        Associe suas instâncias de banco de dados a grupos de segurança e configure esses grupos para permitir apenas tráfego necessário. Restrinja o acesso apenas aos IPs e recursos necessários.
        
        **Use Autenticação e Criptografia:**   
        Implemente autenticação forte e use criptografia para proteger a comunicação entre aplicativos e o banco de dados. Ative a opção de criptografia SSL/TLS.

      EOM
    }   
    table {
      title = "RDS DB instances without graviton processor should be reviewed"
      column "Account ID" {
        display = "none"
      }
      column "ARN" {
        display = "none"
      }
      query = query.rds_db_instance_withou_graviton_processor
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Para otimizar o desempenho e reduzir os custos, considere utilizar instâncias de banco de dados RDS com processadores Graviton (arm64 - arquitetura ARM de 64 bits).   
        Essas instâncias oferecem eficiência energética e um equilíbrio entre desempenho e custo. Além disso, as instâncias Graviton são projetadas para fornecer uma alternativa econômica com bom desempenho para determinados casos de uso.   
        Avalie a compatibilidade de suas cargas de trabalho e experimente as instâncias Graviton para verificar os benefícios específicos para suas necessidades.

      EOM
    }  

  } 
  container {
    title = "VPC"

    container { 
      title = "Security groups should restrict ingress SSH port from 0.0.0.0/0"

      table {
      
        column "Account ID" {
          display = "none"
        }

        column "ARN" {
          display = "none"
        }

        query = query.vpc_security_group_ssh_access
      }
    }

    container { 
      title = "Security groups should restrict ingress RDP port from 0.0.0.0/0"

      table {
      
        column "Account ID" {
          display = "none"
        }

        column "ARN" {
          display = "none"
        }

        query = query.vpc_security_group_rdp_access
      }
    }

    container { 
      title = "Security groups should restrict ingress Database ports from 0.0.0.0/0"

      table {
      
        column "Account ID" {
          display = "none"
        }

        column "ARN" {
          display = "none"
        }

        query = query.vpc_security_group_db_ports_access
      }
    }

    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        A AWS recomenda adotar uma postura de segurança mais rigorosa, evitando ao máximo o uso da regra **0.0.0.0/0** (também conhecida como "anywhere" ou "everyone") em grupos de segurança.   
        Essa regra permite que o tráfego proveniente de qualquer endereço IP acesse os recursos associados ao grupo de segurança, aumentando significativamente o risco de exploração por parte de atacantes.

        Aqui estão algumas recomendações de segurança em relação ao uso de regras **0.0.0.0/0**:

        **Princípio do Menor Privilégio:**   
        Configure regras de grupo de segurança para permitir apenas o tráfego necessário para as operações e serviços específicos.   
        Utilize o princípio do menor privilégio para limitar o acesso somente ao que é essencial.

        **Restrição por Endereços IP:**   
        Evite utilizar **0.0.0.0/0** e, sempre que possível, restrinja as regras para intervalos de endereços IP específicos que precisam acessar seus recursos.

        **Uso de VPN ou Conexões Diretas (Direct Connect):**   
        Considere o uso de VPNs ou conexões diretas para permitir o acesso seguro aos recursos em vez de expor diretamente pela Internet.

      EOM
    } 
  }


  container { 
    title = "EKS"
    table {
      title = "EKS cluster runs on a supported kubernetes version"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.eks_cluster_with_latest_kubernetes_version_table
    } 
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Este controle verifica se um cluster Amazon EKS está sendo executado em uma versão suportada do Kubernetes.   
        O controle considera falha se o cluster EKS estiver sendo executado em uma versão não suportada.

        Se sua aplicação não exigir uma versão específica do Kubernetes, recomendamos que você utilize a versão mais recente disponível do Kubernetes suportada pelo EKS para seus clusters.   
        Para obter mais informações sobre as versões do Kubernetes suportadas para o Amazon EKS, consulte o Calendário de lançamentos do Kubernetes do Amazon EKS e o Suporte à versão do Amazon EKS e Perguntas frequentes no Guia do Usuário do Amazon EKS.
      EOM
    }      
    table {
      title = "EKS cluster endpoint public access restricted"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.eks_cluster_endpoints_should_prohibit_public_table  
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Clusters do EKS com acesso privado permitem que a comunicação entre seus nós e o servidor da API permaneça interna.   
        Este controle está não conforme se o acesso público ao endpoint do cluster estiver habilitado, pois o servidor da API do cluster fica acessível pela internet.
      EOM
    }      
    table {
      title = "EKS cluster secret encrypted"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.eks_cluster_secrets_encrypted_table
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Certifique-se de que os clusters do Amazon Elastic Kubernetes Service (EKS) estejam configurados para ter segredos do Kubernetes criptografados usando chaves do AWS Key Management Service (KMS).
      EOM
    }  
    table {
      title = "EKS clusters should have control plane audit logging enabled"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.eks_cluster_control_plane_audit_logging_enabled_table
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Os clusters do AWS EKS devem ter a auditoria do control plane habilitada.   
        Esses logs facilitam a segurança e a administração eficiente dos clusters.
      EOM
    }      
  }     

  container { 
    title = "CloudFront"
    table {
      title = "CloudFront distributions should have origin access identity enabled"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.cloudfront_distribution_origin_access_identity_enabled_table
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Certifique-se de que uma distribuição do Amazon CloudFront com tipo de origem Amazon S3 tenha a Identidade de Acesso à Origem (OAI) configurada.   
        Este controle considera falha caso a OAI não esteja configurada.

        O uso do CloudFront OAI impede que usuários acessem diretamente o conteúdo do bucket S3.   
        Quando os usuários acessam diretamente um bucket S3, eles contornam efetivamente a distribuição do CloudFront e quaisquer permissões aplicadas ao conteúdo subjacente do bucket S3.
      EOM
    }     
    table {
      title = "CloudFront distributions should encrypt traffic to non S3 origins"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.cloudfront_distribution_non_s3_origins_encryption_in_transit_enabled_table
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Este controle verifica se uma distribuição do Amazon CloudFront exige que os visualizadores usem HTTPS diretamente ou se ela usa redirecionamento.   
        O controle considera falha se o ViewerProtocolPolicy estiver configurado como allow-all para defaultCacheBehavior ou para cacheBehaviors.

        O uso de HTTPS (TLS) pode ajudar a evitar que possíveis atacantes usem ataques do tipo pessoa no meio ou similares para bisbilhotar ou manipular o tráfego de rede.    
        Somente conexões criptografadas via HTTPS (TLS) devem ser permitidas. A criptografia de dados em trânsito pode afetar o desempenho.   
        Recomenda-se testar sua aplicação com essa funcionalidade para entender o perfil de desempenho e o impacto do TLS.
      EOM
    }     
    table {
      title = "CloudFront distributions should have AWS WAF enabled"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.cloudfront_distribution_waf_enabled_table
    }         
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Certifique-se de associar as distribuições do CloudFront a Web ACLs da AWS WAF ou AWS WAFv2.    
        Essa prática é essencial para fortalecer a segurança, garantindo que as distribuições estejam protegidas contra possíveis ameaças.   
        O controle considera falha se a distribuição não estiver associada a um Web ACL.
      EOM
    }              
  }

  container {
    title = "Cloudtrail"
    table {
      title = "At least one CloudTrail trail should be enabled in the AWS account"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.cloudtrail_trail_enabled_account
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        A recomendação da AWS é garantir que pelo menos uma trilha do CloudTrail esteja habilitada na conta da AWS.   
        O CloudTrail fornece registros detalhados de eventos e atividades na sua conta, ajudando na auditoria, conformidade e na resposta a incidentes de segurança.    
        Ter pelo menos uma trilha ativada é crucial para capturar e monitorar essas informações essenciais para a segurança e integridade da sua infraestrutura na AWS.
      EOM
    }         
    table {
      title = "CloudTrail trail log file validation should be enabled"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.cloudtrail_trail_validation_enabled
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Utilize a validação de arquivos de log do AWS CloudTrail para verificar a integridade dos registros do CloudTrail.   
        A validação de arquivos de log ajuda a determinar se um arquivo de log foi modificado, excluído ou permanece inalterado após ser entregue pelo CloudTrail.   
        Essa funcionalidade é construída utilizando algoritmos padrão da indústria: SHA-256 para hash e SHA-256 com RSA para assinatura digital.    
        Isso torna computacionalmente inviável modificar, excluir ou falsificar arquivos de log do CloudTrail sem detecção.
      EOM
    }         
    table {
      title = "CloudTrail trail S3 buckets MFA delete should be enabled"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.cloudtrail_trail_bucket_mfa_enabled
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Garanta a ativação da autenticação multifator (MFA) para a exclusão nos buckets S3 da trilha do CloudTrail.   
        A habilitação da MFA contribui para prevenir exclusões inadvertidas de buckets, uma vez que demanda que o usuário, ao iniciar a ação de exclusão, comprove a posse física de um dispositivo MFA por meio de um código específico.    
        Essa medida adiciona uma camada adicional de segurança e obstáculos à realização da ação de exclusão.
      EOM
    } 
  }
  
  container { 
    title = "LAMBDA"
    table {
      title = "Lambda Function Variables No Sensitive Data"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.lambda_function_variables_no_sensitive_data
    } 
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Certifique-se de que as variáveis ​​de ambiente das funções não contenham dados confidenciais. 
		    Aproveitar o Secrets Manager permite o provisionamento seguro de credenciais de banco de dados para funções Lambda, ao mesmo tempo que garante a segurança dos bancos de dados. 
		    Essa abordagem elimina a necessidade de codificar segredos no código ou passá-los por meio de variáveis ​​ambientais. 
		    Além disso, o Secrets Manager facilita a recuperação segura de credenciais para estabelecer conexões com bancos de dados e realizar consultas, aprimorando as medidas gerais de segurança.
      EOM
    } 
  
    table {
      title = "Lambda Function Cloudtrail Logging Enabled"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.lambda_function_cloudtrail_logging_enabled
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Utilize a validação de arquivos de log do AWS CloudTrail para verificar a integridade dos registros do CloudTrail.   
        A validação de arquivos de log ajuda a determinar se um arquivo de log foi modificado, excluído ou permanece inalterado após ser entregue pelo CloudTrail.   

      EOM
    }
    
    table {
      title = "Lambda Function Use Latest Runtime"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.lambda_function_use_latest_runtime
    }
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        Utilize a validação de arquivos de log do AWS CloudTrail para verificar a integridade dos registros do CloudTrail.   
 
      EOM
    }
  }
  container { 
    title = "ELB"
    table {
      title = "ELB TLS Listener Protocol Version"
      column "Account ID" {
        display = "none"
      }
      #column "ARN" {
      #  display = "none"
      #}
      query = query.elb_tls_listener_protocol_version
    } 
    text {
      #width = 1
      value = <<-EOM
        #### Recomendações:
        CSecrets Manager facilita a recuperação segura de credenciais para estabelecer conexões com bancos de dados e realizar consultas, aprimorando as medidas gerais de segurança.
      EOM
    }
  }
}
