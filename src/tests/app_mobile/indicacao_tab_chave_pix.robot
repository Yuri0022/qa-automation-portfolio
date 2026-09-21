*** Settings ***
Documentation    Valida que "Alterar chave pix" (aba Indicação) abre a tela de
...              cadastro de chave Pix. NÃO altera nem submete nenhum dado —
...              a tela envolve dados bancários reais da conta de teste.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
ALTERAR CHAVE PIX ABRE TELA DE CADASTRO
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    IR PARA ABA INDICACAO
    IR PARA ALTERAR CHAVE PIX
