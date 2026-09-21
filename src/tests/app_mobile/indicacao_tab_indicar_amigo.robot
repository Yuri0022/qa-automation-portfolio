*** Settings ***
Documentation    Valida o formulário "Indique um amigo" (aba Indicação): o
...              botão "Indicar" começa desabilitado, habilita só depois de
...              preencher nome e telefone, e o telefone recebe máscara
...              automática. Também valida a mensagem de erro para telefone
...              incompleto (caminho negativo). NÃO conclui o envio (isso
...              dispararia um convite real para o número informado).
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
FORMULARIO INDICAR AMIGO HABILITA APOS PREENCHER OS CAMPOS
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    IR PARA ABA INDICACAO
    ABRIR FORMULARIO INDICAR AMIGO
    VALIDAR BOTAO INDICAR DESABILITADO
    PREENCHER FORMULARIO INDICAR AMIGO    Teste Automatizado    31999999999
    VALIDAR TELEFONE COM MASCARA APLICADA
    VALIDAR BOTAO INDICAR HABILITADO
    FECHAR FORMULARIO SEM ENVIAR

FORMULARIO INDICAR AMIGO REJEITA TELEFONE INCOMPLETO
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    IR PARA ABA INDICACAO
    ABRIR FORMULARIO INDICAR AMIGO
    Input Text    ${CAMPO_TELEFONE_INDICACAO}    319999
    VALIDAR ERRO DE TELEFONE INVALIDO
    FECHAR FORMULARIO SEM ENVIAR
