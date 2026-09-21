*** Settings ***
Documentation      Cadastro de parceiro Radar pelo caminho logado, dentro do
...                Portal dos Parceiros: .../register-radar/. Usa exatamente o
...                mesmo formulário e o mesmo endpoint do caminho deslogado (ver
...                cadastro_deslogado.robot), mas com 2 diferenças de tela:
...                - Botão extra "Abrir lista de CNAE's disponíveis para cadastro".
...                - Ao contrário do deslogado (que não dá feedback nenhum), o
...                  sucesso aqui redireciona para /radar-register-completed/
...                  (~2s de atraso) — ver VALIDAR TELA DE CADASTRO RADAR
...                  CONCLUIDO no resource.
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/radar-keywords.resource
Resource           ../../keywords/portal-parceiros-keywords.resource
Test Setup         Login no portal dos parceiros
Test Teardown      Run Keyword And Ignore Error    Close Browser    ALL

*** Keywords ***
Login no portal dos parceiros
    ACESSAR PAGINA %{URL_PORTAL}
    REALIZAR LOGIN PORTAL DOS PARCEIROS    %{EMAIL_PORTAL}    %{PASSWORD_PORTAL}

*** Test Cases ***
Cadastro de novo parceiro Radar pelo portal logado é criado com sucesso
    [Tags]    REGRESSAO
    ${cnpj}=    Gerar Cnpj    formatado=True
    ${cpf}=    Gerar Cpf    formatado=True
    ${email}=    FakerLibrary.Email

    IR PARA CADASTRO RADAR LOGADO

    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=Lumen Teste Automatizado LTDA
    ...    razao_social=Lumen Teste Automatizado LTDA
    ...    cnpj=${cnpj}
    ...    tipo_empresa=LTDA
    ...    nome_responsavel=Teste Automatizado
    ...    documento_responsavel=${cpf}
    ...    telefone_responsavel=31999999999
    ...    email_responsavel=${email}
    AVANCAR CADASTRO RADAR

    ANEXAR DOCUMENTOS RADAR
    AVANCAR CADASTRO RADAR

    PREENCHER ETAPA ENDERECO RADAR    cep=31035320    numero=100
    AVANCAR CADASTRO RADAR

    PREENCHER ETAPA FINANCEIRO RADAR
    ...    banco=Banco do Brasil    agencia=0001    conta=123456-7    chave_pix=31999999999

    ${resposta}=    FINALIZAR CADASTRO RADAR
    Should Be Equal As Integers    ${resposta}[status]    201
    ...    Cadastro não foi criado — resposta: ${resposta}[body]

    VALIDAR TELA DE CADASTRO RADAR CONCLUIDO

    CONECTAR SALESFORCE
    VALIDAR CADASTRO RADAR CRIADO NO SALESFORCE
    ...    account_id=${resposta}[body][accountId]
    ...    contact_id=${resposta}[body][contactId]
    ...    nome_empresa=Lumen Teste Automatizado LTDA
    ...    cnpj=${cnpj}
    ...    nome_responsavel=Teste Automatizado
    ...    documento_responsavel=${cpf}
    ...    email_responsavel=${email}

Lista de CNAE's disponíveis abre, filtra e fecha corretamente
    [Documentation]    Recurso exclusivo do caminho logado — ajuda o usuário a
    ...    conferir se o CNAE da empresa é elegível antes de preencher o
    ...    formulário. Não interage com o cadastro em si.
    [Tags]    REGRESSAO
    IR PARA CADASTRO RADAR LOGADO

    ABRIR LISTA DE CNAES DISPONIVEIS
    ${qtd_antes}=    CONTAR LINHAS DA LISTA DE CNAES
    Should Be True    ${qtd_antes} > 0    A lista de CNAE's veio vazia.

    BUSCAR CNAE    publicidade
    Sleep    1s
    ${qtd_depois}=    CONTAR LINHAS DA LISTA DE CNAES
    Should Be True    0 < ${qtd_depois} < ${qtd_antes}
    ...    A busca por "publicidade" deveria filtrar a lista (antes: ${qtd_antes}, depois: ${qtd_depois}).

    FECHAR LISTA DE CNAES
