*** Settings ***
Documentation      Valida a navegação até o número de instalação (usado depois para
...                cruzar dados com o Salesforce). Equivalente web de
...                src/tests/app_mobile/instalacao.robot.
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-titular-keywords.resource
Test Setup         Login comum no portal do titular
Test Teardown      ENCERRAR TESTE PORTAL DO TITULAR

*** Keywords ***
Login comum no portal do titular
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    LOGIN NO PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR}    %{PASSWORD_PORTAL_TITULAR}

*** Test Cases ***
Obter número de instalação pelo menu de perfil
    [Tags]    REGRESSAO
    ABRIR MENU DE PERFIL
    IR PARA RENOMEAR INSTALACAO
    ${numero}=    OBTER NUMERO DA INSTALACAO
    Log    Número de instalação: ${numero}
    Should Match Regexp    ${numero}    ^\\d+$
