*** Settings ***
Documentation      Valida o formulário "Indique um amigo" (aba Indicação): o botão
...                "Indicar" começa desabilitado, habilita só depois de preencher
...                nome e telefone, e o telefone recebe máscara automática. Também
...                valida a mensagem de erro para telefone incompleto (caminho
...                negativo). NÃO conclui o envio (isso dispararia um convite real
...                para o número informado). Equivalente web de
...                src/tests/app_mobile/indicacao_tab_indicar_amigo.robot.
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
Formulário indicar amigo habilita após preencher os campos
    [Tags]    REGRESSAO
    IR PARA ABA INDICACAO
    ABRIR FORMULARIO INDICAR AMIGO
    VALIDAR BOTAO INDICAR DESABILITADO
    PREENCHER FORMULARIO INDICAR AMIGO    Teste Automatizado    31999999999
    VALIDAR TELEFONE COM MASCARA APLICADA
    VALIDAR BOTAO INDICAR HABILITADO
    FECHAR FORMULARIO SEM ENVIAR

Formulário indicar amigo rejeita telefone incompleto
    [Tags]    REGRESSAO    NEGATIVO
    IR PARA ABA INDICACAO
    ABRIR FORMULARIO INDICAR AMIGO
    Fill Text    //input[@placeholder='Insira aqui o telefone']    319999
    VALIDAR ERRO DE TELEFONE INVALIDO
    FECHAR FORMULARIO SEM ENVIAR
