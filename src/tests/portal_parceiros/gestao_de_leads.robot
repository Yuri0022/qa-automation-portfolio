*** Settings ***
Library      ../../../load_env.py
Resource     ../../common/generic-keywords.resource
Resource     ../../keywords/portal-parceiros-keywords.resource

*** Test Cases ***
Acompanhar leads pelo portal
    ACESSAR PAGINA %{URL_PORTAL}

    REALIZAR LOGIN PORTAL DOS PARCEIROS
    ...    %{EMAIL_PORTAL}
    ...    %{PASSWORD_PORTAL}

    CONECTAR SALESFORCE

    SELECIONAR MODULO PORTAL DOS PARCEIROS
    ...    modulo=Acompanhar Leads

    VALIDAR TELA ACOMPANHAR LEADS
    VALIDAR COLUNAS KANBAN
    CONTAR CARDS EM TODAS AS COLUNAS KANBAN
    VALIDAR DADOS DO CARD EM TODAS AS COLUNAS

    COLETAR EVIDENCIA    acompanhamento_leads