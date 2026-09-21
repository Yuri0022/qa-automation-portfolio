*** Settings ***
Documentation      Valida que "Alterar chave pix" (aba Indicação) abre a tela de
...                cadastro de chave Pix. NÃO altera nem submete nenhum dado — a
...                tela envolve dados bancários reais da conta de teste.
...                Equivalente web de src/tests/app_mobile/indicacao_tab_chave_pix.robot.
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
Alterar chave pix abre tela de cadastro
    [Tags]    REGRESSAO
    IR PARA ABA INDICACAO
    IR PARA ALTERAR CHAVE PIX
