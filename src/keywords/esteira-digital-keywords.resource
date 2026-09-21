*** Settings ***
Library       BuiltIn
Library       Browser
Library       Collections

*** Variables ***


*** Keywords ***
SELECIONAR ESTADO DO LEAD
    [Arguments]    ${uf}
    @{estados}=    Create List    RS    PI    PE    MG    MT    GE    CE    BA
    ${contemEstado}=    Evaluate    $uf in $estados

    # Abre o picklist 
    Click    //input[@placeholder='Informe o estado']

    IF    ${contemEstado}
        ${index}=    Get Index From List    ${estados}    ${uf}

        FOR    ${i}    IN RANGE    ${index}
            Press Keys    //input[@placeholder='Informe o estado']    ArrowDown
        END
        
        Press Keys    //input[@placeholder='Informe o estado']    Enter
    ELSE
        Log To Console    Estado não encontrado
    END

APLICAR CODIGO DE INDICACAO
    [Arguments]    ${code}=

    IF    "'${code} == ''"
        Log To Console    \nCódigo de indicação não informado.
    ELSE
        Fill Text   //input[@placeholder='Código de indicação (opcional)']    ${code}
    END

APLICAR CUPOM
    [Arguments]    ${code}=

    IF    "'${code}' == ''" 
        Log To Console    \nCódigo de cupom não informado.
    ELSE
        Fill Text   //input[@placeholder='Aplicar cupom (opcional)']    ${code}
    END

PREENCHER FORMULARIO CADASTRO LEAD
    [Arguments]    
        ...     ${name}=    
        ...     ${cpf}=    
        ...     ${email}=    
        ...     ${cellphone}=    
        ...     ${state}=    
        ...     ${energy_value}=    
        ...     ${invite_code}=    
        ...     ${coupon}=

    Fill Text    //input[@placeholder='Nome completo do titular da conta']    ${name}

    Fill Text    //input[@placeholder='Insira o CPF ou CNPJ do titular']    ${cpf}

    Fill Text    //input[@placeholder='E-mail para contato do titular']    ${email}

    Fill Text    //input[@placeholder='DDD + Número do celular']    ${cellphone}

    SELECIONAR ESTADO DO LEAD    uf=${state}

    Fill Text    //input[@placeholder='Qual o valor da sua conta de luz?']    ${energy_value}

    APLICAR CODIGO DE INDICACAO    code=${invite_code}

    APLICAR CUPOM    code=${coupon}

    Click    //*[@id="privacyPolicy"]

    COLETAR EVIDENCIA    
    ...    file_name=1-formulário-cadastro-lead

    # Avançar para próxima etapa
    Wait For Elements State    //button[text()='Avançar']    visible    10s
    Click    //button[text()='Avançar']

    Sleep    5s

VERIFICAR SIMULACAO
    Wait For Elements State    //button[text()='Quero meu benefício']    visible    10s

    COLETAR EVIDENCIA    
    ...    file_name=2-simulacao-beneficio

    Click    //button[text()='Quero meu benefício']

    Sleep    5s

ANEXAR CONTA CLIENTE PF
    Wait For Elements State    //button[text()='Anexar arquivo']     visible    10s
    
    COLETAR EVIDENCIA    
    ...    file_name=3-anexar-conta-de-energia

    Upload File By Selector    //*[@id="file-upload"]       ./src/docs/Fatura-Cliente.pdf

    Sleep    5s

PREENCHER DADOS ENDERECO
    [Arguments]    
    ...    ${class}=Monofásico    
    ...    ${subclass}=Residencial    
    ...    ${tipoImovel}=Próprio
    # @{classes}=    Create List    Monofásico    Bifásico    Trifásico
    # ${contemClasse}=    Evaluate    $class in $classes
    # @{subclasses}=    Create List    Residencial    Comercial    Rural    Serviços    Irrigante Noturno
    # ${contemSubclasse}=    Evaluate    $subclass in $subclasses
    @{tipoImoveis}=    Create List    Próprio    Alugado
    ${contemTipoImovel}=    Evaluate    $tipoImovel in $tipoImoveis

    # Wait For Elements State    //input[@placeholder='Selecione a classe da conta']    visible    15s
    # Click    //input[@placeholder='Selecione a classe da conta']
    
    # # Classe da conta
    # IF    ${contemClasse}
    #     Fill Text    //input[@placeholder='Selecione a classe da conta']    ${class}
    # ELSE
    #     Log To Console    Classe informada não encontrada.
    # END

    # # Subclasse da conta
    # IF    ${contemSubclasse}
    #     Fill Text    //input[@placeholder='Selecione a subclasse da conta']    ${subclass}
    # ELSE
    #     Log To Console    Subclasse informada não encontrada.
    # END

    # Numero da residência:
    Wait For Elements State    //input[@placeholder='Número']    visible    20s
    Fill Text    //input[@placeholder='Número']    48

    # Selecionar o tipo de imóvel:
    IF    '${tipoImovel}' == 'Próprio'
        Click    //html/body/main/div/main/div[2]/form/div[6]/label[1]/input
    ELSE IF    '${tipoImovel}' == 'Alugado'
        Click    //html/body/main/div/main/div[2]/form/div[6]/label[2]/input
    ELSE
        Log To Console    Tipo do imóvel inválido: ${tipoImovel}
    END

    # Confirmar o preenchimento do endereço
    Wait For Elements State    //button[text()='Confirmar']    visible    10s

    COLETAR EVIDENCIA    
    ...    file_name=4-preenchimento-endereco-lead

    Click    //button[text()='Confirmar']

    # Seguir com a contratação
    Wait For Elements State    //button[text()='Seguir com contratação']    visible    10s
    Click    //button[text()='Seguir com contratação'] 


ANEXAR DOCUMENTACAO CLIENTE PF
    # FRENTE DO RG
    Wait For Elements State    //button[text()='Anexar documento']     visible    10s

    COLETAR EVIDENCIA    
    ...    file_name=5-tela-anexo-frente-rg

    # Frente do RG é um template fixo (sem campos por lead) versionado em
    # src/templates/ — ao contrário do verso, não precisa ser gerado a cada
    # execução em src/docs/ (pasta ignorada pelo git).
    Upload File By Selector    //html/body/main/input    src/templates/rg-frente.png

    Sleep    10s

    # VERSO DO RG
    Wait For Elements State    //button[text()='Anexar verso do documento']     visible    10s

    COLETAR EVIDENCIA    
    ...    file_name=6-tela-anexo-verso-rg

    Upload File By Selector    //html/body/main/input    src/docs/rg-verso.pdf

    Sleep    10s

PREENCHER COMPLEMENTO DE DADOS PESSOAIS
    [Arguments]    ${profissao}=Desempregado    ${estadoCivil}=solteiro
    @{estadosCivis}=    Create List    ...    solteiro    casado    divorciado    viuvo
    ${contemEstadoCivil}=    Evaluate    $estadoCivil in $estadosCivis

    # Abre o picklist de estado cívil
    Wait For Elements State    //html/body/main/main/div[2]/form/select    visible    10s
    Click    //html/body/main/main/div[2]/form/select

    IF    ${contemEstadoCivil}
        ${index}=    Get Index From List    ${estadosCivis}    ${estadoCivil}

        FOR    ${i}    IN RANGE    ${index}
            Press Keys    //html/body/main/main/div[2]/form/select    ArrowDown
        END
        
        Press Keys    //html/body/main/main/div[2]/form/select    Enter
    ELSE
        Log To Console    Estado Cívil não encontrado
    END

    # Profissão:
    Fill Text    //input[@placeholder='Profissão']     ${profissao}

    # Avançar proximo etapa:
    Wait For Elements State    //button[text()='Confirmar']    visible    10s

    COLETAR EVIDENCIA    
    ...    file_name=7-informacoes-complementares-lead

    Click    //button[text()='Confirmar']

SELECIONAR RESPONSAVEL FINANCEIRO
    Wait For Elements State     //button[text()='Confirmar']      visible     20s

    COLETAR EVIDENCIA    
    ...    file_name=8-selecionar-responsavel-financeiro
    
    Click      //button[text()='Confirmar']
VISUALIZAR O CONTRATO
    # 30s não é sempre suficiente (confirmado, reproduzido 2x): a
    # página /contract-visualization/ mostra um loading ("Conectando você à
    # energia limpa...") enquanto o contrato é gerado no servidor, e isso pode
    # passar de 30s. Mesma causa raiz do timeout de download já ajustado em
    # BAIXAR CONTA LUMEN (portal-titular-keywords.resource).
    Wait For Elements State     //button[text()='Visualizar contrato']      visible     90s
    Click      //button[text()='Visualizar contrato']

    COLETAR EVIDENCIA    
    ...    file_name=9-visualizar-o-contrato

    sleep   15s

IR PARA O FAQ
    Go To       https://digital-dev.lumenenergia.com.br/faq/

    COLETAR EVIDENCIA
    ...    file_name=10-pop-up-contratacao

    # Aguarda a pesquisa de satisfação aparecer e dispensa com "Responder
    # depois" — não respondemos a pesquisa em si, só encerramos o fluxo.
    Wait For Elements State
    ...    //*[contains(text(),'Responder depois')]
    ...    visible
    ...    60s

    COLETAR EVIDENCIA
    ...    file_name=11-pesquisa-de-satisfacao

    Click    (//*[contains(text(),'Responder depois')])[last()]

    Sleep    3s