*** Settings ***
Documentation        keywords genericas para reutilização...
Library        Browser
Library        BuiltIn
Library        Collections
Library        FakerLibrary    locale=pt_BR
Library        String
Library        ../services/pdf_service.py
Library        ../services/rg_service.py
Library        ../services/cpf_generator.py
Library        ../services/cnpj_generator.py

*** Keywords ***

ACESSAR PAGINA ${url_pagina}
    # O caminho do navegador é configurável via variável de ambiente
    # BROWSER_EXECUTABLE_PATH (definida no .env). Se estiver vazia, usa o
    # chromium empacotado do Playwright (padrão em CI e na maioria das
    # máquinas). Máquinas onde o chromium empacotado não inicia (ex.: falta
    # do msvcp140_1.dll / VC++ Redistributable) podem apontar para um Chrome
    # instalado no sistema definindo essa variável no seu .env local.
    ${browser_path}=    Set Variable    %{BROWSER_EXECUTABLE_PATH=}

    IF    '${browser_path}' == ''
        New Browser    browser=chromium    headless=False
    ELSE
        New Browser    browser=chromium    executablePath=${browser_path}    headless=False
    END

    New Context
    New Page    ${url_pagina}
    Wait For Load State    domcontentloaded

CRIAR FATURA CLIENTE PF
    [Documentation]    Gera a fatura (PDF) de uma UC para anexar na esteira.
    ...    ${consumo_mensal_kwh}, quando informado, sobrescreve o consumo
    ...    fixo do template (~6000 kWh/mes, sempre reportado como ~5373 kWh
    ...    pelo portal) -- necessario para testar cenarios de consumo
    ...    baixo/alto (ex.: regra de negocio por limite de consumo (kWh)). Ver
    ...    src/services/pdf_service.py.
    [Arguments]
    ...    ${installation_number}
    ...    ${cpf}
    ...    ${name}
    ...    ${reference_date}
    ...    ${due_date}
    ...    ${value}
    ...    ${class}
    ...    ${subclass}
    ...    ${tariff_type}
    ...    ${consumo_mensal_kwh}=${EMPTY}

    ${installation_number}    Convert To String    ${installation_number}
    ${cpf}                    Convert To String    ${cpf}
    ${name}                   Convert To String    ${name}
    ${reference_date}         Convert To String    ${reference_date}
    ${due_date}               Convert To String    ${due_date}

    ${formatted_value}=    Evaluate    f"{float(${value})/100:.2f}".replace('.', ',')
    ${formattad_value}    Convert To String    ${formatted_value}

    ${class}                  Convert To String    ${class}
    ${subclass}               Convert To String    ${subclass}
    ${tariff_type}            Convert To String    ${tariff_type}

    IF    '${consumo_mensal_kwh}' == ''
        ${arquivo}=    Gerar Pdf
            ...        ${installation_number}
            ...        ${cpf}
            ...        ${name}
            ...        Rua da felicidade, n480
            ...        ${reference_date}
            ...        ${due_date}
            ...        ${formatted_value}
            ...        ${class}
            ...        ${subclass}
            ...        ${tariff_type}
    ELSE
        ${arquivo}=    Gerar Pdf
            ...        ${installation_number}
            ...        ${cpf}
            ...        ${name}
            ...        Rua da felicidade, n480
            ...        ${reference_date}
            ...        ${due_date}
            ...        ${formatted_value}
            ...        ${class}
            ...        ${subclass}
            ...        ${tariff_type}
            ...        consumo_mensal_kwh=${consumo_mensal_kwh}
    END

GERAR DOCUMENTO RG
    [Arguments]    ${rg}    ${shipping_date}    ${name}    ${father_name}    ${mother_name}    ${naturalness}    ${birthdate}    ${cpf}

    ${rg}               Convert To String    ${rg}
    ${shipping_date}    Convert To String    ${shipping_date}
    ${name}             Convert To String    ${name}
    ${father_name}      Convert To String    ${father_name}
    ${mother_name}      Convert To String    ${mother_name}
    ${naturalness}      Convert To String    ${naturalness}
    ${birthdate}        Convert To String    ${birthdate}
    ${cpf}              Convert To String    ${cpf}

    ${arquivo}=    Gerar Rg
        ...        ${rg}
        ...        ${shipping_date}
        ...        ${name}
        ...        ${father_name}
        ...        ${mother_name}
        ...        ${naturalness}
        ...        ${birthdate}
        ...        ${cpf}

GERAR MASSA DE DADOS COMPLETA
    ${lead_name}=            FakerLibrary.Name
    # Remove títulos (Sr., Sra., Dr., etc.) e pontos residuais do nome
    ${lead_name}=    Evaluate    re.sub(r'\b(Sr|Sra|Srta|Dr|Dra|Prof|Profa)\.?\s+', '', '''${lead_name}''', flags=re.IGNORECASE)    modules=re
    ${lead_name}=    Replace String    ${lead_name}    .    ${EMPTY}
    ${lead_name}=    Evaluate    ' '.join('''${lead_name}'''.split())

    ${lead_cpf}=             Gerar Cpf    formatado=True
    ${lead_email}=           FakerLibrary.Email
    ${lead_state}=           FakerLibrary.RandomChoices    elements=('RN', 'PI', 'PE', 'MG', 'MT', 'GO', 'CE', 'BA')    length=1
    ${lead_energy_value}=    FakerLibrary.RandomInt    min=10000    max=100000    step=1
    ${lead_housing_type}=           FakerLibrary.RandomChoices    elements=('Próprio', 'Alugado')    length=1

    # Dados da conta energia:
    ${lead_installation_number}=    FakerLibrary.RandomInt    min=2990000000    max=2999999999    step=1
    ${lead_class}=                  FakerLibrary.RandomChoices    elements=('Monofásico', 'Bifásico', 'Trifásico')    length=1
    ${lead_subclass}=               FakerLibrary.RandomChoices    elements=('Residencial', 'Comercial')    length=1
    ${lead_tariff_type}=            FakerLibrary.RandomChoices    elements=('Convencional B1')    length=1

    # Dados do documento de Identificação:
    ${lead_father}=              FakerLibrary.NameMale
    ${lead_mother}=              FakerLibrary.NameFemale
    ${lead_naturalness}=         FakerLibrary.City
    ${lead_birthdate}=           FakerLibrary.DateOfBirth    minimum_age=18    maximum_age=60

    

    &{massa_dados}=    Create Dictionary
        ...            name=${lead_name}
        ...            cpf=${lead_cpf}
        ...            email=${lead_email}
        ...            state=${lead_state}
        ...            energy_value=${lead_energy_value}
        ...            installation_number=${lead_installation_number}
        ...            housing_type=${lead_housing_type}
        ...            class=${lead_class}
        ...            subclass=${lead_subclass}
        ...            tariff_type=${lead_tariff_type}
        ...            father_name=${lead_father}
        ...            mother_name=${lead_mother}
        ...            naturalness=${lead_naturalness}
        ...            birthdate=${lead_birthdate}

    Log To Console     Lead Criado: ${lead_name}
        
    RETURN    ${massa_dados}

COLETAR EVIDENCIA
    [Arguments]    ${file_name}=
    Take Screenshot    filename=../../../screenshots/${file_name}    fileType=png    fullPage=True