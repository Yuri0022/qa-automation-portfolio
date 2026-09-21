*** Settings ***
Library      ../../../load_env.py
Resource     ../../common/generic-keywords.resource
Resource     ../../keywords/portal-parceiros-keywords.resource

*** Test Cases ***
Acompanhar vendas pelo portal
    [Documentation]    Percorre a lista "Minhas vendas" do Portal dos Parceiros,
    ...    validando o formato dos dados de cada venda (nome, status, número de
    ...    instalação, telefone, data de criação) e cruzando com o Salesforce
    ...    pelo número de instalação (UnidadeConsumidora__c), em todas as páginas.
    [Tags]    REGRESSAO

    ACESSAR PAGINA %{URL_PORTAL}

    REALIZAR LOGIN PORTAL DOS PARCEIROS
    ...    %{EMAIL_PORTAL}
    ...    %{PASSWORD_PORTAL}

    CONECTAR SALESFORCE

    SELECIONAR MODULO PORTAL DOS PARCEIROS
    ...    modulo=Acompanhar vendas

    VALIDAR TELA ACOMPANHAR VENDAS
    VALIDAR TODAS AS VENDAS

    COLETAR EVIDENCIA    acompanhamento_vendas
