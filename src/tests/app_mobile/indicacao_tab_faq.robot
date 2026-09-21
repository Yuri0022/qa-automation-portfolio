*** Settings ***
Documentation    Valida que "Como funciona o Rede Lumen+?" (aba Indicação)
...              abre a tela de dúvidas sobre o programa de indicação.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
COMO FUNCIONA ABRE TELA DE DUVIDAS
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    IR PARA ABA INDICACAO
    ABRIR COMO FUNCIONA INDICACAO
