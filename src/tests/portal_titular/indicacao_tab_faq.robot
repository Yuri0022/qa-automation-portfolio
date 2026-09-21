*** Settings ***
Documentation      Valida que "Como funciona o Rede Lumen+?" (aba Indicação) abre a
...                tela de dúvidas sobre o programa de indicação. Equivalente web de
...                src/tests/app_mobile/indicacao_tab_faq.robot.
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
Como funciona abre tela de dúvidas
    [Tags]    REGRESSAO
    IR PARA ABA INDICACAO
    ABRIR COMO FUNCIONA INDICACAO
