*** Settings ***
Documentation      Testes do banner de indicação ("SUA INDICAÇÃO VALE PIX SEM LIMITES!")
...                exibido na home do Portal do Titular após o login.
...
...                Este fluxo já foi um popup sobreposto à página; hoje é um banner fixo
...                na própria home, renderizado como uma única imagem (ver documentação
...                de VALIDAR BANNER INDICACAO). O botão "Consulte aqui o regulamento"
...                que existia no popup antigo não tem mais equivalente na tela atual.
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
Validar banner de indicação na home
    [Documentation]    Garante que o banner de indicação aparece na home após o login.
    [Tags]    SMOKE
    VALIDAR BANNER INDICACAO

Validar clique no banner de indicação
    [Documentation]    Garante que clicar no banner de indicação abre o
    ...    compartilhamento padrão via WhatsApp com a mensagem fixa (mesma
    ...    mensagem/PIN do app mobile, confirmado — mesmo backend).
    [Tags]    REGRESSAO
    @{paginas_antes}=    CLICAR NO BANNER INDICACAO
    VALIDAR MENSAGEM PADRAO DE INDICACAO    ${paginas_antes}
