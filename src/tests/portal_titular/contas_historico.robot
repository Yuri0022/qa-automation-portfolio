*** Settings ***
Documentation      Valida que "Ver histórico completo de contas" (aba Contas) abre a
...                lista com o histórico de faturas do cliente. Equivalente web de
...                src/tests/app_mobile/contas_historico.robot.
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
Histórico completo de contas mostra várias faturas
    [Tags]    REGRESSAO
    IR PARA ABA CONTAS
    IR PARA HISTORICO COMPLETO DE CONTAS
    VALIDAR LISTA DE HISTORICO DE CONTAS
