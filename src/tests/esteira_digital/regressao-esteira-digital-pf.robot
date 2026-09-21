*** Settings ***
Library            ../../../load_env.py
Resource           ../../keywords/esteira-digital-keywords.resource
Resource           ../../common/generic-keywords.resource

*** Test Cases ***
REGRESSAO-ESTEIRA-DIGITAL-PF
    [Documentation]        Teste de regressão esteira digital PF
    [tags]    REGRESSAO
    &{lead}=    GERAR MASSA DE DADOS COMPLETA

    GERAR DOCUMENTO RG
        ...        rg=50.227.543-1
        ...        shipping_date=09/06/2026
        ...        name=${lead}[name]
        ...        father_name=${lead}[father_name]
        ...        mother_name=${lead}[mother_name]
        ...        naturalness=${lead}[naturalness]
        ...        birthdate=${lead}[birthdate]
        ...        cpf=${lead}[cpf]

    CRIAR FATURA CLIENTE PF
        ...        installation_number=${lead}[installation_number]
        ...        cpf=${lead}[cpf]
        ...        name=${lead}[name]
        ...        reference_date=MAI/2050
        ...        due_date=12/05/2050
        ...        value=${lead}[energy_value]
        ...        class=Monofásico
        ...        subclass=Residencial
        ...        tariff_type=Convencional B1
        
    ACESSAR PAGINA %{URL_BASE}

    PREENCHER FORMULARIO CADASTRO LEAD
        ...        name=${lead}[name]
        ...        cpf=${lead}[cpf]
        ...        email=${lead}[email]
        ...        cellphone=31912345678
        ...        state=MG
        ...        energy_value=${lead}[energy_value]
        ...        invite_code=${NULL}
        ...        coupon=${NULL}

    VERIFICAR SIMULACAO

    ANEXAR CONTA CLIENTE PF

    PREENCHER DADOS ENDERECO

    ANEXAR DOCUMENTACAO CLIENTE PF

    PREENCHER COMPLEMENTO DE DADOS PESSOAIS    profissao=Motorista de Uber

    SELECIONAR RESPONSAVEL FINANCEIRO

    VISUALIZAR O CONTRATO

    IR PARA O FAQ