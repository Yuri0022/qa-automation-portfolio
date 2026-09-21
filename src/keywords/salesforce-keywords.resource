*** Settings ***
Library      ../API/salesforce_keywords.py    WITH NAME    SalesforceAPI
Variables    ../../load_env.py


*** Keywords ***
CONECTAR SALESFORCE
    SalesforceAPI.Conectar Salesforce


BUSCAR LEADS POR CPF
    [Arguments]    ${cpf}

    ${resultado}=    SalesforceAPI.Buscar Leads Por CPF    ${cpf}

    RETURN    ${resultado}


BUSCAR CONTRATOS POR CPF
    [Arguments]    ${cpf}

    ${resultado}=    SalesforceAPI.Buscar Contratos Por CPF    ${cpf}

    RETURN    ${resultado}


BUSCAR CONTATO POR CPF
    [Arguments]    ${cpf}

    ${resultado}=    SalesforceAPI.Buscar Contato Por CPF    ${cpf}

    RETURN    ${resultado}


EXECUTAR SOQL
    [Arguments]    ${soql}

    ${resultado}=    SalesforceAPI.Executar Soql    ${soql}

    RETURN    ${resultado}


LISTAR CAMPOS DO OBJETO
    [Arguments]    ${object_name}

    ${resultado}=    SalesforceAPI.Listar Campos Do Objeto    ${object_name}

    RETURN    ${resultado}


BUSCAR TRANSACOES POR INSTALACAO
    [Arguments]    ${numero_instalacao}

    ${resultado}=    SalesforceAPI.Buscar Transacoes Por Instalacao    ${numero_instalacao}

    RETURN    ${resultado}


VALIDAR FATURA CONTRA SALESFORCE
    [Arguments]    ${numero_instalacao}    ${mes_referencia}    ${ano}    ${valor_ui}
    ...    ${vencimento_ui}    ${status_ui}    ${economia_ui}    ${sem_lumen_ui}

    ${resultado}=    SalesforceAPI.Validar Fatura Contra Salesforce
    ...    ${numero_instalacao}    ${mes_referencia}    ${ano}    ${valor_ui}
    ...    ${vencimento_ui}    ${status_ui}    ${economia_ui}    ${sem_lumen_ui}

    RETURN    ${resultado}


BUSCAR UNIDADE CONSUMIDORA POR INSTALACAO
    [Arguments]    ${numero_instalacao}

    ${resultado}=    SalesforceAPI.Buscar Unidade Consumidora Por Instalacao    ${numero_instalacao}

    RETURN    ${resultado}


VALIDAR BANNER UNIFICACAO CONTRA SALESFORCE
    [Arguments]    ${numero_instalacao}    ${texto_banner_ui}

    ${resultado}=    SalesforceAPI.Validar Banner Unificacao Contra Salesforce
    ...    ${numero_instalacao}    ${texto_banner_ui}

    RETURN    ${resultado}
