*** Settings ***
Documentation      Valida que o banner de unificação de contas (aba Contas) reflete
...                a regra de negócio definida em
...                UnidadeConsumidoraDoConsorcio__c.FaturaDistribuidoraNaoUnificada__c
...                (mesma regra e mesma keyword de validação usadas pelo app mobile —
...                ver src/tests/app_mobile/contas_unificacao.robot):
...                "Não Unificado" -> "Sua conta não está unificada."
...                "Unificado" / "Unificado Especial" -> "Sua conta está unificada."
...
...                ATENÇÃO: assim como no app mobile, só é 100% válido quando
...                SALESFORCE_AUTH_URL aponta para o mesmo ambiente que o portal
...                em teste consulta. Ver README.md, seção "Limitação conhecida".
Library            ../../../load_env.py
Library            Browser
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-titular-keywords.resource
Resource           ../../keywords/salesforce-keywords.resource
Suite Setup        CONECTAR SALESFORCE
Test Teardown      ENCERRAR TESTE PORTAL DO TITULAR

*** Test Cases ***
Banner de unificação deve refletir a regra do Salesforce
    [Tags]    REGRESSAO
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    LOGIN NO PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR}    %{PASSWORD_PORTAL_TITULAR}

    ABRIR MENU DE PERFIL
    IR PARA RENOMEAR INSTALACAO
    ${numero_instalacao}=    OBTER NUMERO DA INSTALACAO
    VOLTAR
    VOLTAR

    IR PARA ABA CONTAS
    ${texto_banner}=    OBTER TEXTO DO BANNER DE UNIFICACAO

    VALIDAR BANNER UNIFICACAO CONTRA SALESFORCE    ${numero_instalacao}    ${texto_banner}
