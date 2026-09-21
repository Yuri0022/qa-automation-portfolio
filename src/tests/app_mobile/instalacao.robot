*** Settings ***
Documentation    Valida a navegação até o número de instalação (usado depois para
...              cruzar dados com o Salesforce).
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
OBTER NUMERO DE INSTALACAO PELO MENU DE PERFIL
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME
    ABRIR MENU DE PERFIL
    IR PARA RENOMEAR INSTALACAO
    ${numero}=    OBTER NUMERO DA INSTALACAO
    Log    Número de instalação: ${numero}
    Should Match Regexp    ${numero}    ^\\d+$
