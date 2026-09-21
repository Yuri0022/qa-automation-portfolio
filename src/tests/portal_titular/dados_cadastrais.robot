*** Settings ***
Documentation      Testes de alteração de e-mail cadastral do titular, com validação
...                cruzada no Salesforce (Contact) via API.
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-titular-keywords.resource
Test Setup         Login comum no portal do titular
Test Teardown      ENCERRAR TESTE PORTAL DO TITULAR

*** Keywords ***
Login comum no portal do titular
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    LOGIN NO PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR}    %{PASSWORD_PORTAL_TITULAR}
    ACESSAR DADOS CADASTRAIS

*** Test Cases ***
Validar alteração do e-mail do titular com sucesso
    [Documentation]    Atualiza o e-mail cadastral do titular para um valor válido,
    ...    confirma a mensagem de sucesso, valida no Salesforce que o e-mail
    ...    persistiu no Contact e reverte o e-mail para o valor original.
    [Tags]    REGRESSAO
    CONECTAR SALESFORCE
    ${email_novo}=    GERAR EMAIL DE TESTE

    ALTERAR EMAIL DO TITULAR    ${email_novo}
    CLICAR EM ATUALIZAR
    CONFIRMAR ATUALIZACAO
    VALIDAR MENSAGEM DE SUCESSO NA ATUALIZACAO
    VALIDAR EMAIL DO TITULAR NO SALESFORCE    %{CPF_TITULAR}    ${email_novo}

    ALTERAR EMAIL DO TITULAR    %{EMAIL_PORTAL_TITULAR}
    CLICAR EM ATUALIZAR
    CONFIRMAR ATUALIZACAO
    VALIDAR MENSAGEM DE SUCESSO NA ATUALIZACAO
    VALIDAR EMAIL DO TITULAR NO SALESFORCE    %{CPF_TITULAR}    %{EMAIL_PORTAL_TITULAR}

Validar alteração do e-mail do titular com erro
    [Documentation]    Garante que um e-mail em formato inválido é rejeitado com
    ...    mensagem de erro. O modal de confirmação "Tem certeza?" aparece
    ...    normalmente mesmo com e-mail inválido — a validação só ocorre ao
    ...    confirmar, por isso CONFIRMAR ATUALIZACAO é necessário aqui também.
    ...
    ...    Também valida, via Salesforce, que o e-mail original permanece
    ...    intacto após a tentativa. Esse passo existe porque,,
    ...    uma tentativa manual de e-mail inválido feita durante o
    ...    desenvolvimento deste teste chegou a persistir no Contact mesmo com
    ...    a mensagem de erro sendo exibida na tela — o que derrubou o login da
    ...    conta de teste. Se o mesmo voltar a acontecer, este teste deve falhar
    ...    aqui (mensagem de erro exibida na tela não é garantia de que o
    ...    backend rejeitou a alteração).
    [Tags]    REGRESSAO    NEGATIVO
    CONECTAR SALESFORCE
    ${email_invalido}=    GERAR EMAIL INVALIDO DE TESTE

    ALTERAR EMAIL DO TITULAR    ${email_invalido}
    CLICAR EM ATUALIZAR
    CONFIRMAR ATUALIZACAO
    VALIDAR MENSAGEM DE ERRO NA ATUALIZACAO
    VALIDAR EMAIL DO TITULAR NO SALESFORCE    %{CPF_TITULAR}    %{EMAIL_PORTAL_TITULAR}
