*** Settings ***
Documentation    Valida que "Ver histórico completo de contas" (aba Contas)
...              abre a lista com o histórico de faturas do cliente.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
HISTORICO COMPLETO DE CONTAS MOSTRA VARIAS FATURAS
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    IR PARA ABA CONTAS
    IR PARA HISTORICO COMPLETO DE CONTAS
    VALIDAR LISTA DE HISTORICO DE CONTAS
