*** Settings ***
Documentation    Valida que o banner de unificação de contas (aba Contas) reflete
...              a regra de negócio definida em
...              UnidadeConsumidoraDoConsorcio__c.FaturaDistribuidoraNaoUnificada__c:
...              "Não Unificado" -> "Sua conta não está unificada."
...              "Unificado" / "Unificado Especial" -> "Sua conta está unificada."
...
...              ATENÇÃO: este teste só é 100% válido quando SALESFORCE_AUTH_URL
...              aponta para o MESMO ambiente que o app em teste consulta (o
...              app mobile BETA usa produção). Ver README.md, seção
...              "Limitação conhecida".
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Resource    ../../keywords/salesforce-keywords.resource
Suite Setup    CONECTAR SALESFORCE
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
BANNER DE UNIFICACAO DEVE REFLETIR A REGRA DO SALESFORCE
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    ABRIR MENU DE PERFIL
    IR PARA RENOMEAR INSTALACAO
    ${numero_instalacao}=    OBTER NUMERO DA INSTALACAO
    VOLTAR
    VOLTAR

    IR PARA ABA CONTAS
    ${texto_banner}=    OBTER TEXTO DO BANNER DE UNIFICACAO

    VALIDAR BANNER UNIFICACAO CONTRA SALESFORCE    ${numero_instalacao}    ${texto_banner}
