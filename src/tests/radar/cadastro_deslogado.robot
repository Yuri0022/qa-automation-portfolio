*** Settings ***
Documentation      Cadastro de parceiro Radar pelo caminho deslogado (público,
...                sem precisar de conta no Portal dos Parceiros):
...                https://parceiro-dev.lumenenergia.com.br/register-radar-forms/
...
...                A tela não dá nenhum feedback visual em caso de SUCESSO (só
...                reseta o formulário em silêncio) — por isso os testes de
...                sucesso validam a resposta da API + a criação real do
...                Account/Contact no Salesforce, não uma mensagem na tela.
...                Já o erro de duplicidade É exibido normalmente (banner
...                vermelho no topo). Confirmado — se a tela de
...                sucesso ganhar uma confirmação visual no futuro, vale
...                acrescentar essa validação aqui também.
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/radar-keywords.resource
Test Teardown      Run Keyword And Ignore Error    Close Browser    ALL

*** Keywords ***
Preencher cadastro Radar completo
    [Arguments]
    ...    ${nome_empresa}    ${cnpj}    ${nome_responsavel}    ${documento_responsavel}
    ...    ${telefone_responsavel}    ${email_responsavel}
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=${nome_empresa}
    ...    razao_social=${nome_empresa}
    ...    cnpj=${cnpj}
    ...    tipo_empresa=LTDA
    ...    nome_responsavel=${nome_responsavel}
    ...    documento_responsavel=${documento_responsavel}
    ...    telefone_responsavel=${telefone_responsavel}
    ...    email_responsavel=${email_responsavel}
    AVANCAR CADASTRO RADAR

    ANEXAR DOCUMENTOS RADAR
    AVANCAR CADASTRO RADAR

    PREENCHER ETAPA ENDERECO RADAR    cep=31035320    numero=100    complemento=Sala 1
    AVANCAR CADASTRO RADAR

    PREENCHER ETAPA FINANCEIRO RADAR
    ...    banco=Banco do Brasil    agencia=0001    conta=123456-7    chave_pix=${telefone_responsavel}

*** Test Cases ***
Cadastro de novo parceiro Radar é criado com sucesso
    [Tags]    REGRESSAO
    ${cnpj}=    Gerar Cnpj    formatado=True
    ${cpf}=    Gerar Cpf    formatado=True
    ${email}=    FakerLibrary.Email

    IR PARA CADASTRO RADAR DESLOGADO
    Preencher cadastro Radar completo
    ...    nome_empresa=Lumen Teste Automatizado LTDA
    ...    cnpj=${cnpj}
    ...    nome_responsavel=Teste Automatizado
    ...    documento_responsavel=${cpf}
    ...    telefone_responsavel=31999999999
    ...    email_responsavel=${email}

    ${resposta}=    FINALIZAR CADASTRO RADAR
    Should Be Equal As Integers    ${resposta}[status]    201
    ...    Cadastro não foi criado — resposta: ${resposta}[body]

    CONECTAR SALESFORCE
    VALIDAR CADASTRO RADAR CRIADO NO SALESFORCE
    ...    account_id=${resposta}[body][accountId]
    ...    contact_id=${resposta}[body][contactId]
    ...    nome_empresa=Lumen Teste Automatizado LTDA
    ...    cnpj=${cnpj}
    ...    nome_responsavel=Teste Automatizado
    ...    documento_responsavel=${cpf}
    ...    email_responsavel=${email}

Cadastro duplicado é rejeitado com mensagem de erro
    [Documentation]    Registra uma vez (sucesso) e tenta registrar de novo com
    ...    exatamente os mesmos dados — a API rejeita com HTTP 400 e a tela
    ...    mostra o erro normalmente.
    [Tags]    REGRESSAO    NEGATIVO
    ${cnpj}=    Gerar Cnpj    formatado=True
    ${cpf}=    Gerar Cpf    formatado=True
    ${email}=    FakerLibrary.Email

    IR PARA CADASTRO RADAR DESLOGADO
    Preencher cadastro Radar completo
    ...    nome_empresa=Lumen Teste Duplicidade LTDA
    ...    cnpj=${cnpj}
    ...    nome_responsavel=Teste Automatizado
    ...    documento_responsavel=${cpf}
    ...    telefone_responsavel=31999999999
    ...    email_responsavel=${email}
    ${resposta_1}=    FINALIZAR CADASTRO RADAR
    Should Be Equal As Integers    ${resposta_1}[status]    201
    ...    Primeiro cadastro deveria ter sido criado — resposta: ${resposta_1}[body]

    IR PARA CADASTRO RADAR DESLOGADO
    Preencher cadastro Radar completo
    ...    nome_empresa=Lumen Teste Duplicidade LTDA
    ...    cnpj=${cnpj}
    ...    nome_responsavel=Teste Automatizado
    ...    documento_responsavel=${cpf}
    ...    telefone_responsavel=31999999999
    ...    email_responsavel=${email}
    ${resposta_2}=    FINALIZAR CADASTRO RADAR
    Should Be Equal As Integers    ${resposta_2}[status]    400
    VALIDAR ERRO DE CADASTRO DUPLICADO
