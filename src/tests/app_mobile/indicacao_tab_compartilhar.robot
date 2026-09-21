*** Settings ***
Documentation    Valida que o botão "Compartilhar" da aba Indicação (menu
...              inferior) abre o mesmo compartilhamento com a mensagem
...              padrão do banner de indicação da home. Não conclui o envio.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
COMPARTILHAR NA ABA INDICACAO USA A MESMA MENSAGEM PADRAO
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    IR PARA ABA INDICACAO
    CLICAR EM COMPARTILHAR INDICACAO
    VALIDAR MENSAGEM PADRAO DE INDICACAO
    SELECIONAR COMPARTILHAMENTO VIA MENSAGENS
    CONFIRMAR DIRECIONAMENTO PARA ENVIO
    CANCELAR COMPARTILHAMENTO SEM ENVIAR
