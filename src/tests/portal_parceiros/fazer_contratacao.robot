*** Settings ***
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-parceiros-keywords.resource
Resource           ../../keywords/esteira-digital-keywords.resource

*** Test Cases ***
REALIZAR CONTRATACAO PELO PORTAL
    [Documentation]    Realizar contratação do Lead pelo Portal do Parceiro
    [Tags]    REGRESSAO
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
    ACESSAR PAGINA https://parceiro-dev.lumenenergia.com.br/login/
    REALIZAR LOGIN PORTAL DOS PARCEIROS    
        ...     email=%{EMAIL_PORTAL}    
        ...     password=%{PASSWORD_PORTAL}
    SELECIONAR MODULO PORTAL DOS PARCEIROS
        ...     modulo=Fazer contratação
    PREENCHER FORMULARIO BENEFICIO PORTAL DOS PARCEIROS     
        ...         name=${lead}[name]
        ...         cpf=${lead}[cpf]
        ...         email=${lead}[email]
        ...         celular=31912345678
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
    ANEXAR CONTA CLIENTE PF
    PREENCHER DADOS ENDERECO
        ...     profissao=Motorista de Uber
    CUSTOMIZAR PRODUTO CLIENTE ESTEIRA
    SELECIONAR COMO DESEJA CONTINUAR A CONTRATACAO     
        ...     tipo_contratacao=Seguir com a contratação
    ANEXAR DOCUMENTACAO CLIENTE PF
    PREENCHER COMPLEMENTO DE DADOS PESSOAIS    profissao=Motorista de Uber
    Sleep   60s