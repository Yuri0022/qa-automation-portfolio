*** Settings ***
Documentation    Fluxo de login: trata a permissão de notificação e autentica no app.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
LOGIN COM CREDENCIAIS VALIDAS
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME
