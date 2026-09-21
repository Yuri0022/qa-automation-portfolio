*** Settings ***
Documentation      Valida que o botão "Compartilhar" da aba Indicação abre o mesmo
...                compartilhamento com a mensagem padrão do banner de indicação da
...                home. Equivalente web de
...                src/tests/app_mobile/indicacao_tab_compartilhar.robot.
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
Compartilhar na aba indicação usa a mesma mensagem padrão
    [Tags]    REGRESSAO
    IR PARA ABA INDICACAO
    @{paginas_antes}=    Get Page Ids
    CLICAR EM COMPARTILHAR INDICACAO
    VALIDAR MENSAGEM PADRAO DE INDICACAO    ${paginas_antes}
