
dashboard "report" {

  title         = "Ops Team Report"

  tags = merge(local.aws_common_tags, {
    type     = "Report"
    category = "Compliance"
  })

  container {
    width = 9
    

    image {
      src = "https://ops.team/wp-content/uploads/2023/06/logo2-1.png"
      alt = "Ops Team Logo"
      width = 2

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

        Recomenda-se realizar a rotação regular de chaves na AWS para aumentar a segurança e reduzir o risco de comprometimento de credenciais.  
        Implemente boas práticas, como a rotação regular de chaves, para fortalecer a segurança da conta AWS, reduzir o risco de acesso não autorizado e garantir o cumprimento de políticas de segurança.    
        Considere a automação desse processo para simplificar a gestão de chaves e manter a conformidade ao longo do tempo.

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
  }
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
    
    container{
      title = "EKS"
      container { 
        title = "EKS cluster runs on a supported kubernetes version"

        table {
        
          column "Account ID" {
            display = "none"
          }

          #column "ARN" {
          #  display = "none"
          #}

          query = query.eks_cluster_with_latest_kubernetes_version_table
        }
      }
      container { 
        title = "EKS cluster endpoint public access restricted"

        table {
        
          column "Account ID" {
            display = "none"
          }

          #column "ARN" {
          #  display = "none"
          #}

          query = query.eks_cluster_endpoints_should_prohibit_public_table
        }
      }
      container { 
        title = "EKS cluster secret encrypted"

        table {
        
          column "Account ID" {
            display = "none"
          }

          #column "ARN" {
          #  display = "none"
          #}

          query = query.eks_cluster_secrets_encrypted_table
        }
      }
      container { 
        title = "EKS cluster control plane audit logging enabled"

        table {
        
          column "Account ID" {
            display = "none"
          }

          #column "ARN" {
          #  display = "none"
          #}

          query = query.eks_cluster_control_plane_audit_logging_enabled_table
        }
      }      
    }  
  }

  container {

    container{
      title = "CloudFront"

      container { 
        title = "Distribuitions origin access identity not enabled"

        table {
        
          column "Account ID" {
            display = "none"
          }

          #column "ARN" {
          #  display = "none"
          #}

          query = query.cloudfront_distribution_origin_access_identity_enabled_table
        }
      }  
      container { 
        title = "CloudFront distributions should encrypt traffic to non S3 origins"

        table {
        
          column "Account ID" {
            display = "none"
          }

          #column "ARN" {
          #  display = "none"
          #}

          query = query.cloudfront_distribution_non_s3_origins_encryption_in_transit_enabled_table
        }
      } 
      container { 
        title = "CloudFront distributions should have AWS WAF enabled"

        table {
        
          column "Account ID" {
            display = "none"
          }

          #column "ARN" {
          #  display = "none"
          #}

          query = query.cloudfront_distribution_waf_enabled_table
        }
      }                
    }  
  }

  container {

    container{
      title = "Cloudtrail"

      container { 
        title = "At least one CloudTrail trail should be enabled in the AWS account"

        table {
        
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
      }   
      container { 
        title = "CloudTrail trail log file validation should be enabled"

        table {
        
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
      }       
      container { 
        title = "CloudTrail trail S3 buckets MFA delete should be enabled"

        table {
        
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
    }  
  }
}


