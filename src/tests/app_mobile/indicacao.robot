*** Settings ***
Documentation    Valida o banner de indicação na home: abre o compartilhamento com a
...              mensagem padrão (incluindo o PIN do cliente) e confirma que o
...              direcionamento para um app de envio funciona. Não conclui o envio.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
BANNER DE INDICACAO ABRE COMPARTILHAMENTO COM MENSAGEM PADRAO
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME
    ABRIR BANNER DE INDICACAO
    VALIDAR MENSAGEM PADRAO DE INDICACAO
    SELECIONAR COMPARTILHAMENTO VIA MENSAGENS
    CONFIRMAR DIRECIONAMENTO PARA ENVIO
    CANCELAR COMPARTILHAMENTO SEM ENVIAR
