*** Settings ***
Library       BuiltIn
Library       Browser
Library       Collections
Resource      salesforce-keywords.resource

*** Keywords ***

REALIZAR LOGIN PORTAL DOS PARCEIROS
    [Arguments]    ${email}    ${password}

    Wait For Elements State    //input[@placeholder='E-mail']    visible    10s
    Fill Text    //input[@placeholder='E-mail']    ${email}

    Wait For Elements State    //input[@placeholder='Insira sua senha']    visible    10s
    Fill Text    //input[@placeholder='Insira sua senha']    ${password}

    Wait For Elements State    //button[text()='Avançar']    visible    10s
    Click    //button[text()='Avançar']

SELECIONAR MODULO PORTAL DOS PARCEIROS
    [Arguments]    ${modulo}

    @{modulos_disponiveis}=    Create List
    ...     Simular economia
    ...     Fazer contratação
    ...     Acompanhar o Funil
    ...     Acompanhar vendas
    ...     Acompanhar Leads

    ${contem_modulo}=    Run Keyword And Return Status
    ...    List Should Contain Value
    ...    ${modulos_disponiveis}
    ...    ${modulo}

    IF    ${contem_modulo}
            Wait For Elements State     //span[text()='${modulo}']      visible     10s
            Click   //span[text()='${modulo}']
    ELSE
        Log To Console    Modulo informado não encontrado.
    END

PREENCHER FORMULARIO BENEFICIO PORTAL DOS PARCEIROS
    [Arguments]     
        ...     ${name}
        ...     ${cpf}
        ...     ${email}
        ...     ${celular}

    Wait For Elements State     //input[@placeholder='Nome completo do titular da conta']       visible     10s
    Fill Text   //input[@placeholder='Nome completo do titular da conta']       ${name}
    Fill Text   //input[@placeholder='Insira o CPF ou CNPJ do titular']       ${cpf}
    Fill Text   //input[@placeholder='E-mail para contato do titular']       ${email}
    Fill Text   //input[@placeholder='DDD + Número do celular']       ${celular}

    Wait For Elements State     //button[text()='Avançar']      visible     10s
    Click   //button[text()='Avançar']


VALIDAR TELA ACOMPANHAR LEADS
    Wait For Elements State
    ...    text=Leads Dashboard
    ...    visible
    ...    20s

    Wait For Elements State
    ...    input[placeholder="Buscar"]
    ...    visible
    ...    20s

    AGUARDAR CARREGAMENTO DO KANBAN


AGUARDAR CARREGAMENTO DO KANBAN
    [Documentation]
    ...    Aguarda o quadro Kanban renderizar antes das validações. As
    ...    keywords de validação usam Get Element Count, que NÃO espera; sem
    ...    esta sincronização o teste roda contra a página ainda vazia e
    ...    encerra antes do conteúdo aparecer.
    ...
    ...    Usa polling por contagem (Get Element Count, que não sofre com o
    ...    strict mode do Wait For Elements State — o seletor casa com várias
    ...    colunas). Assim que ao menos uma coluna aparece na tela, segue.

    Wait Until Keyword Succeeds    30s    1s    KANBAN POSSUI COLUNAS


KANBAN POSSUI COLUNAS
    [Documentation]
    ...    Falha (para o retry do Wait Until Keyword Succeeds) enquanto
    ...    nenhuma coluna do Kanban estiver presente na tela.

    ${qtd}=    Get Element Count
    ...    xpath=//div[contains(@class,'rounded-xl')]

    Should Be True
    ...    ${qtd} > 0
    ...    O quadro Kanban ainda não carregou (nenhuma coluna visível).

    RETURN    ${qtd}


OBTER COLUNAS KANBAN
    @{colunas}=    Create List
    ...    Novo
    ...    Upload conta de energia
    ...    Elegibilidade Manual
    ...    Seleção do plano
    ...    Envio de proposta
    ...    Upload de documentos da empresa
    ...    Upload de documentos pessoais
    ...    Cadastro de contato comercial
    ...    Cadastro de representante legal
    ...    Cadastro de contato financeiro
    ...    Seleção de forma de pagamento
    ...    Aguardando documentação de representantes
    ...    Desqualificado
    ...    Não Qualificado
    ...    Inelegível
    ...    Convertido
    ...    Qualificado
    ...    Aguardando Assinatura

    RETURN    @{colunas}


COLUNA KANBAN EXISTE
    [Arguments]    ${coluna}

    ${qtd}=    Get Element Count
    ...    xpath=//span[normalize-space()='${coluna}']

    ${existe}=    Evaluate    ${qtd} > 0

    RETURN    ${existe}


VALIDAR COLUNAS KANBAN
    @{colunas}=    OBTER COLUNAS KANBAN

    FOR    ${coluna}    IN    @{colunas}
        ${existe}=    COLUNA KANBAN EXISTE    ${coluna}

        IF    ${existe}
            Log To Console
            ...    ✓ Coluna encontrada: ${coluna}
        ELSE
            Log To Console
            ...    Coluna não exibida: ${coluna}
        END
    END


CONTAR CARDS EM TODAS AS COLUNAS KANBAN
    @{colunas}=    OBTER COLUNAS KANBAN

    FOR    ${coluna}    IN    @{colunas}
        ${existe}=    COLUNA KANBAN EXISTE    ${coluna}

        IF    not ${existe}
            Log To Console
            ...    Coluna "${coluna}" não encontrada. Ignorando...
            CONTINUE
        END

        ${qtd}=    Get Element Count
        ...    xpath=//span[normalize-space()='${coluna}']/ancestor::div[contains(@class,'rounded-xl')][1]//div[contains(@class,'bg-white') and contains(@class,'rounded-lg') and contains(@class,'shadow-sm')]

        Log To Console
        ...    ${coluna}: ${qtd} card(s)
    END


VALIDAR DADOS DO CARD EM TODAS AS COLUNAS
    @{colunas}=    OBTER COLUNAS KANBAN

    FOR    ${coluna}    IN    @{colunas}
        ${existe}=    COLUNA KANBAN EXISTE    ${coluna}

        IF    not ${existe}
            Log To Console
            ...    Coluna "${coluna}" não encontrada. Ignorando...
            CONTINUE
        END

        ${qtd}=    Get Element Count
        ...    xpath=//span[normalize-space()='${coluna}']/ancestor::div[contains(@class,'rounded-xl')][1]//div[contains(@class,'bg-white') and contains(@class,'rounded-lg') and contains(@class,'shadow-sm')]

        Log To Console
        ...    Validando ${qtd} card(s) da coluna ${coluna}

        FOR    ${i}    IN RANGE    1    ${qtd + 1}
            ${base}=    Set Variable
            ...    (//span[normalize-space()='${coluna}']/ancestor::div[contains(@class,'rounded-xl')][1]//div[contains(@class,'bg-white') and contains(@class,'rounded-lg') and contains(@class,'shadow-sm')])[${i}]

            Run Keyword And Continue On Failure
            ...    VALIDAR CARD KANBAN
            ...    ${base}
            ...    ${coluna}
        END
    END


VALIDAR CARD KANBAN
    [Documentation]
    ...    Valida um único card do Kanban (formato dos dados exibidos +
    ...    nome e status no Salesforce). Chamada via "Run Keyword And
    ...    Continue On Failure" para que a divergência de um card não impeça
    ...    a validação dos demais cards/colunas na mesma execução.
    [Arguments]    ${base}    ${coluna}

    ${nome_card}=    Get Text
    ...    xpath=${base}//p

    ${email}=    Get Text
    ...    xpath=${base}//span[contains(@class,'break-words')]

    ${telefone}=    Get Text
    ...    xpath=${base}//img[contains(@src,'phone.svg')]/following-sibling::span

    ${data}=    Get Text
    ...    xpath=${base}//img[contains(@src,'calendar.svg')]/following-sibling::span

    ${kwh}=    Get Text
    ...    xpath=${base}//img[contains(@src,'energy.svg')]/following-sibling::span

    Should Not Be Empty
    ...    ${nome_card}
    ...    O nome do card está vazio.

    Should Not Be Empty
    ...    ${email}
    ...    O e-mail do card está vazio.

    Should Not Be Empty
    ...    ${telefone}
    ...    O telefone do card está vazio.

    Should Match Regexp
    ...    ${data}
    ...    \\d{2}/\\d{2}/\\d{4}
    ...    A data do card possui formato inválido.

    Should Match Regexp
    ...    ${kwh}
    ...    \\d+(\.\\d+)?\\s*kWh
    ...    O consumo do card possui formato inválido.

    TRY
        ${cpf}    ${nome_portal}=    ABRIR CARD E CAPTURAR CPF
        ...    ${base}

        Log To Console
        ...    Validando Lead ${nome_portal} (${cpf})

        VALIDAR LEAD SALESFORCE
        ...    ${cpf}
        ...    ${nome_portal}
        ...    ${coluna}
    FINALLY
        FECHAR DETALHE DO LEAD
    END


VALIDAR LEAD SALESFORCE
    [Documentation]
    ...    Valida o Lead exibido no card do portal contra os registros do
    ...    Salesforce para o mesmo CPF/CNPJ: (1) o nome e (2) se o Status do
    ...    Lead corresponde à coluna do Kanban em que o card está.
    ...
    ...    Pode existir mais de um Lead para o mesmo CPF (ex.: recadastro
    ...    após correção de um Lead anterior com dados errados). Por isso a
    ...    validação é considerada OK se o nome/status do portal corresponder
    ...    a QUALQUER UM dos Leads retornados, e só falha se nenhum bater.
    [Arguments]    ${cpf}    ${nome_portal}    ${coluna}

    @{leads}=    BUSCAR LEADS POR CPF    ${cpf}

    ${qtd_leads}=    Get Length    ${leads}

    IF    ${qtd_leads} > 1
        Log To Console
        ...    ⚠ ${qtd_leads} leads encontrados no Salesforce para o CPF ${cpf} (possível duplicidade)
    END

    ${encontrado}=    Set Variable    ${False}
    @{nomes_encontrados}=    Create List

    FOR    ${lead}    IN    @{leads}
        ${nome_salesforce}=    Set Variable    ${lead}[Name]
        Append To List    ${nomes_encontrados}    ${nome_salesforce}

        ${confere}=    Run Keyword And Return Status
        ...    Should Be Equal As Strings
        ...    ${nome_portal}
        ...    ${nome_salesforce}
        ...    ignore_case=True
        ...    strip_spaces=True
        ...    collapse_spaces=True

        IF    ${confere}
            ${encontrado}=    Set Variable    ${True}
            BREAK
        END
    END

    IF    not ${encontrado}
        ${nomes_exibidos}=    Set Variable    ${nomes_encontrados}

        IF    ${qtd_leads} > 10
            @{nomes_exibidos}=    Get Slice From List    ${nomes_encontrados}    0    10
            ${restantes}=    Evaluate    ${qtd_leads} - 10
            Append To List    ${nomes_exibidos}    ... e mais ${restantes} nome(s)
        END

        Fail
        ...    Nome divergente. Portal: "${nome_portal}" | Nenhum dos ${qtd_leads} lead(s) do Salesforce corresponde: ${nomes_exibidos}
    END

    Log To Console
    ...    ✓ Nome validado: ${nome_portal}

    VALIDAR STATUS NA COLUNA    ${coluna}    ${cpf}    ${leads}


VALIDAR STATUS NA COLUNA
    [Documentation]
    ...    Valida se o registro está na coluna correta do Kanban conforme o
    ...    Status no Salesforce. Para a maioria das colunas o Status vem do
    ...    objeto Lead; a coluna "Aguardando Assinatura" é validada pelo
    ...    Status do objeto Contract. Considera OK se QUALQUER registro do
    ...    CPF tiver o Status esperado (tolerante a CPFs com múltiplos
    ...    registros). Colunas sem Status correspondente (ex.: "Convertido")
    ...    não são validadas.
    [Arguments]    ${coluna}    ${cpf}    ${leads}

    IF    '${coluna}' == 'Aguardando Assinatura'
        VALIDAR STATUS DO CONTRATO    ${coluna}    ${cpf}
        RETURN
    END

    @{status_aceitos}=    STATUS ACEITOS PARA COLUNA    ${coluna}
    ${qtd_aceitos}=    Get Length    ${status_aceitos}

    IF    ${qtd_aceitos} == 0
        Log To Console
        ...    ⏭ Coluna "${coluna}" não é validada por Status (sem valor correspondente no objeto Lead).
        RETURN
    END

    ${status_ok}=    Set Variable    ${False}
    @{status_encontrados}=    Create List

    FOR    ${lead}    IN    @{leads}
        ${status_lead}=    Set Variable    ${lead}[Status]
        Append To List    ${status_encontrados}    ${status_lead}

        ${match}=    Evaluate    $status_lead in $status_aceitos

        IF    ${match}
            ${status_ok}=    Set Variable    ${True}
            BREAK
        END
    END

    Should Be True
    ...    ${status_ok}
    ...    Coluna divergente. Card na coluna "${coluna}" (Status aceitos: ${status_aceitos}), mas o(s) Lead(s) do CPF têm Status: ${status_encontrados}

    Log To Console
    ...    ✓ Status validado: coluna "${coluna}" (Status: ${status_encontrados})


VALIDAR STATUS DO CONTRATO
    [Documentation]
    ...    Valida a coluna "Aguardando Assinatura" pelo Status do objeto
    ...    Contract (não há esse valor no Status do Lead). Considera OK se
    ...    QUALQUER Contract do CPF estiver com Status "Aguardando
    ...    Assinatura".
    [Arguments]    ${coluna}    ${cpf}

    @{contratos}=    BUSCAR CONTRATOS POR CPF    ${cpf}

    ${qtd}=    Get Length    ${contratos}

    Should Be True
    ...    ${qtd} > 0
    ...    Card na coluna "${coluna}", mas nenhum Contract encontrado no Salesforce para o CPF ${cpf}.

    ${status_ok}=    Set Variable    ${False}
    @{status_encontrados}=    Create List

    FOR    ${contrato}    IN    @{contratos}
        ${status_contrato}=    Set Variable    ${contrato}[Status]
        Append To List    ${status_encontrados}    ${status_contrato}

        IF    '${status_contrato}' == 'Aguardando Assinatura'
            ${status_ok}=    Set Variable    ${True}
            BREAK
        END
    END

    Should Be True
    ...    ${status_ok}
    ...    Coluna divergente. Card na coluna "${coluna}", mas nenhum Contract do CPF está em "Aguardando Assinatura". Status encontrados: ${status_encontrados}

    Log To Console
    ...    ✓ Status validado (Contract): coluna "${coluna}"


STATUS ACEITOS PARA COLUNA
    [Documentation]
    ...    Retorna a lista de valores de API do campo Status do Lead que são
    ...    aceitos para uma coluna do Kanban. A maioria das colunas tem um
    ...    único valor idêntico ao nome. Exceções:
    ...    - "Desqualificado" e "Não Qualificado" são sinônimos no funil
    ...      (lead descartado): aceitam "Unqualified" (padrão) ou
    ...      "Desqualificado" (resíduo legado da base).
    ...    - "Convertido": sem valor correspondente no Lead -> lista vazia
    ...      (não validada). "Aguardando Assinatura" é tratada à parte, via
    ...      o Status do Contract.
    [Arguments]    ${coluna}

    IF    '${coluna}' == 'Convertido'
        @{vazio}=    Create List
        RETURN    @{vazio}
    END

    IF    '${coluna}' == 'Desqualificado' or '${coluna}' == 'Não Qualificado'
        @{aceitos}=    Create List    Unqualified    Desqualificado
        RETURN    @{aceitos}
    END

    @{aceitos}=    Create List    ${coluna}
    RETURN    @{aceitos}


ABRIR CARD E CAPTURAR CPF
    [Arguments]    ${base}

    Click    xpath=${base}

    Wait For Elements State
    ...    xpath=//label[normalize-space()='CPF/CNPJ:']/following-sibling::input
    ...    visible
    ...    10s

    ${cpf}=    Get Attribute
    ...    xpath=//label[normalize-space()='CPF/CNPJ:']/following-sibling::input
    ...    value

    ${primeiro_nome}=    Get Attribute
    ...    xpath=//label[normalize-space()='Primeiro nome:']/following-sibling::input
    ...    value

    ${sobrenome}=    Get Attribute
    ...    xpath=//label[normalize-space()='Sobrenome:']/following-sibling::input
    ...    value

    ${nome}=    Set Variable
    ...    ${primeiro_nome} ${sobrenome}

    Should Not Be Empty
    ...    ${cpf}
    ...    O CPF/CNPJ do Lead está vazio.

    Should Not Be Empty
    ...    ${nome}
    ...    O nome do Lead está vazio.

    Log To Console
    ...    CPF/CNPJ: ${cpf}

    Log To Console
    ...    Nome: ${nome}

    RETURN    ${cpf}    ${nome}


FECHAR DETALHE DO LEAD
    Wait For Elements State
    ...    xpath=//button[.//*[name()='svg' and contains(@class,'lucide-x')]]
    ...    visible
    ...    5s

    Click
    ...    xpath=//button[.//*[name()='svg' and contains(@class,'lucide-x')]]

    Wait For Elements State
    ...    xpath=//label[normalize-space()='CPF/CNPJ:']/following-sibling::input
    ...    hidden
    ...    5s

CUSTOMIZAR PRODUTO CLIENTE ESTEIRA
    Wait For Elements State    //button[text()='Avançar']      visible     10s
    Click       //button[text()='Avançar']

SELECIONAR COMO DESEJA CONTINUAR A CONTRATACAO
    [Arguments]     ${tipo_contratacao}

    @{opcoes_disponiveis}=    Create List
    ...     Enviar a proposta ao cliente
    ...     Seguir com a contratação

    ${contem_opcao}=    Run Keyword And Return Status
    ...    List Should Contain Value
    ...    ${opcoes_disponiveis}
    ...    ${tipo_contratacao}

    IF    ${contem_opcao}
            Wait For Elements State     //button[text()='${tipo_contratacao}']      visible     10s
            Click   //button[text()='${tipo_contratacao}']
    ELSE
        Log To Console    Opção informada não encontrado.
    END

    Wait For Elements State     //button[text()='Confirmar']    visible     10s
    Click   //button[text()='Confirmar']

    Wait For Elements State     //button[text()='Confirmar']    visible     10s
    Click   //button[text()='Confirmar']


# ---------------------------------------------------------------------------
# Módulo "Acompanhar vendas"
#
# Diferente do Kanban de "Acompanhar Leads", esta tela é uma LISTA paginada
# ("Minhas vendas"): cada card mostra nome + status colapsados, e expande
# (clique no nome/seta) revelando Número de instalação, Status, Telefone e
# Data de criação. Não há CPF/CNPJ visível na tela — por isso o cruzamento
# com o Salesforce é feito pelo Número de instalação (Transacao__c), não
# por CPF como em Leads.
# ---------------------------------------------------------------------------

VALIDAR TELA ACOMPANHAR VENDAS
    [Documentation]    Garante que a tela "Minhas vendas" carregou e aguarda ao
    ...    menos um card ser renderizado antes de seguir com as validações.
    Wait For Elements State
    ...    text=Minhas vendas
    ...    visible
    ...    20s

    Wait For Elements State
    ...    text=Acompanhe o status das suas simulações de venda.
    ...    visible
    ...    20s

    AGUARDAR CARREGAMENTO DA LISTA DE VENDAS


AGUARDAR CARREGAMENTO DA LISTA DE VENDAS
    [Documentation]
    ...    Mesmo racional de "AGUARDAR CARREGAMENTO DO KANBAN": Get Element
    ...    Count não espera sozinho, então roda em polling até aparecer ao
    ...    menos 1 card de venda na tela.
    Wait Until Keyword Succeeds    30s    1s    LISTA DE VENDAS POSSUI CARDS


LISTA DE VENDAS POSSUI CARDS
    ${qtd}=    Get Element Count
    ...    xpath=//div[contains(@class,'rounded-xl') and contains(@class,'bg-gray') and contains(@class,'max-w-[416px]')]

    Should Be True
    ...    ${qtd} > 0
    ...    A lista de vendas ainda não carregou (nenhum card visível).

    RETURN    ${qtd}


CONTAR CARDS DA PAGINA ATUAL DE VENDAS
    ${qtd}=    Get Element Count
    ...    xpath=//div[contains(@class,'rounded-xl') and contains(@class,'bg-gray') and contains(@class,'max-w-[416px]')]

    RETURN    ${qtd}


EXPANDIR CARD DE VENDA
    [Documentation]    Clica na área superior do card (nome + seta) do card de
    ...    índice ${indice} (1-based) na página atual, expandindo os detalhes.
    ...    Retorna o XPath base do card, para as demais keywords lerem os
    ...    dados sem precisar re-localizar o elemento.
    [Arguments]    ${indice}

    ${base}=    Set Variable
    ...    (//div[contains(@class,'rounded-xl') and contains(@class,'bg-gray') and contains(@class,'max-w-[416px]')])[${indice}]

    Click    xpath=${base}//div[contains(@class,'cursor-pointer')][1]

    Wait For Elements State
    ...    xpath=${base}//*[name()='svg' and contains(@class,'lucide-chevron-up')]
    ...    visible
    ...    5s

    RETURN    ${base}


CAPTURAR NUMEROS DE INSTALACAO DO CARD DE VENDA
    [Documentation]    Alguns cards têm mais de uma instalação vinculada — nesse
    ...    caso o rótulo aparece no plural ("Números de instalação") com um <p>
    ...    por número, em vez do singular ("Número de instalação") com um único
    ...    valor. O locator casa com os dois (starts-with "Número"), e sempre
    ...    retorna uma lista — com 1 item no caso comum de instalação única.
    [Arguments]    ${base}

    ${qtd}=    Get Element Count
    ...    xpath=${base}//span[starts-with(normalize-space(),'Número')]/following-sibling::div//p

    @{instalacoes}=    Create List

    FOR    ${i}    IN RANGE    1    ${qtd + 1}
        ${valor}=    Get Text
        ...    xpath=(${base}//span[starts-with(normalize-space(),'Número')]/following-sibling::div//p)[${i}]
        Append To List    ${instalacoes}    ${valor}
    END

    RETURN    @{instalacoes}


CAPTURAR DADOS DO CARD DE VENDA
    [Documentation]    Lê, de um card já expandido (ver "EXPANDIR CARD DE
    ...    VENDA"), o nome do cliente e os detalhes: Status, Telefone, Data de
    ...    criação e a lista de números de instalação vinculados.
    [Arguments]    ${base}

    ${nome}=    Get Text    xpath=${base}//h3

    ${status}=    Get Text
    ...    xpath=${base}//span[normalize-space()='Status']/following-sibling::p

    ${telefone}=    Get Text
    ...    xpath=${base}//span[normalize-space()='Telefone']/following-sibling::p

    ${data_criacao}=    Get Text
    ...    xpath=${base}//span[normalize-space()='Data de criação']/following-sibling::p

    @{instalacoes}=    CAPTURAR NUMEROS DE INSTALACAO DO CARD DE VENDA    ${base}

    RETURN    ${nome}    ${status}    ${telefone}    ${data_criacao}    @{instalacoes}


VALIDAR FORMATO DOS DADOS DA VENDA
    [Documentation]    Valida que os campos do card de venda vieram
    ...    preenchidos e nos formatos esperados.
    [Arguments]    ${nome}    ${status}    ${telefone}    ${data_criacao}    ${instalacoes}

    Should Not Be Empty
    ...    ${nome}
    ...    O nome do cliente está vazio.

    Should Not Be Empty
    ...    ${status}
    ...    O status da venda está vazio.

    ${qtd_instalacoes}=    Get Length    ${instalacoes}

    IF    ${qtd_instalacoes} == 0
        # TODO: confirmar com o time se isso é esperado (venda em estágio
        # inicial do funil, ainda sem conta de energia/instalação vinculada)
        # ou se é uma divergência do portal. Por ora não falha o teste, só
        # avisa e pula a validação de instalação/Salesforce deste card.
        Log To Console
        ...    ⚠ Card "${nome}" sem número de instalação vinculado (Status: ${status}) — pulando validação de instalação/Salesforce.
        RETURN
    END

    FOR    ${instalacao}    IN    @{instalacoes}
        Should Match Regexp
        ...    ${instalacao}
        ...    ^\\d+$
        ...    O número de instalação possui formato inválido: "${instalacao}".
    END

    Should Match Regexp
    ...    ${telefone}
    ...    \\(\\d{2}\\)\\s?\\d{4,5}-\\d{4}
    ...    O telefone possui formato inválido: "${telefone}".

    Should Match Regexp
    ...    ${data_criacao}
    ...    \\d{2}/\\d{2}/\\d{4},\\s?\\d{2}:\\d{2}:\\d{2}
    ...    A data de criação possui formato inválido: "${data_criacao}".


VALIDAR VENDA CONTRA SALESFORCE
    [Documentation]
    ...    Confirma que existe uma UnidadeConsumidora__c no Salesforce para
    ...    cada número de instalação exibido no card (um card pode ter mais
    ...    de uma instalação vinculada).
    ...
    ...    Nota: cruzamos com o objeto UnidadeConsumidora__c (via SOQL direto
    ...    — EXECUTAR SOQL), NÃO com UnidadeConsumidoraDoConsorcio__c (objeto
    ...    usado por "BUSCAR UNIDADE CONSUMIDORA POR INSTALACAO", que serve
    ...    para outra finalidade — o banner de unificação — e não tem esses
    ...    registros). Também não usamos Transacao__c — essa só é criada mais
    ...    adiante no funil, depois que a primeira fatura é gerada, então
    ...    quase nenhuma venda ainda em estágio inicial teria uma.
    [Arguments]    ${instalacoes}

    FOR    ${instalacao}    IN    @{instalacoes}
        ${soql}=    Set Variable
        ...    SELECT Id, NumeroInstalacao__c FROM UnidadeConsumidora__c WHERE NumeroInstalacao__c = '${instalacao}'

        ${resultado}=    EXECUTAR SOQL    ${soql}

        Should Be True
        ...    ${resultado}[totalSize] > 0
        ...    Nenhuma UnidadeConsumidora__c encontrada no Salesforce para a instalação ${instalacao}.

        Log To Console
        ...    ✓ Unidade consumidora validada: instalação ${instalacao} (Id ${resultado}[records][0][Id])
    END


VALIDAR VENDAS DA PAGINA ATUAL
    [Documentation]    Expande e valida todos os cards de venda visíveis na
    ...    página atual da lista (formato dos dados + existência no
    ...    Salesforce). Usa "Run Keyword And Continue On Failure" para que a
    ...    divergência de um card não impeça a validação dos demais.
    ${qtd}=    CONTAR CARDS DA PAGINA ATUAL DE VENDAS

    FOR    ${i}    IN RANGE    1    ${qtd + 1}
        ${base}=    EXPANDIR CARD DE VENDA    ${i}
        ${nome}    ${status}    ${telefone}    ${data_criacao}    @{instalacoes}=
        ...    CAPTURAR DADOS DO CARD DE VENDA    ${base}

        Log To Console
        ...    Validando venda: ${nome} (instalação(ões): ${instalacoes})

        Run Keyword And Continue On Failure
        ...    VALIDAR FORMATO DOS DADOS DA VENDA    ${nome}    ${status}    ${telefone}    ${data_criacao}    ${instalacoes}
        Run Keyword And Continue On Failure    VALIDAR VENDA CONTRA SALESFORCE    ${instalacoes}
    END


NAVEGAR PARA PROXIMA PAGINA DE VENDAS
    [Documentation]    Clica no botão de próxima página (seta) da paginação e
    ...    confirma que a lista realmente mudou, comparando o nome do
    ...    primeiro card antes/depois. Retorna ${False} sem clicar quando o
    ...    botão de próxima página não existe mais (já estava na última) ou
    ...    quando a página não muda mesmo após o clique.
    ${existe_botao}=    Run Keyword And Return Status
    ...    Wait For Elements State
    ...    xpath=//button[.//*[name()='svg' and contains(@class,'lucide-arrow-right')]]
    ...    visible
    ...    3s

    IF    not ${existe_botao}
        RETURN    ${False}
    END

    ${primeiro_nome_antes}=    Get Text
    ...    xpath=(//div[contains(@class,'rounded-xl') and contains(@class,'bg-gray') and contains(@class,'max-w-[416px]')])[1]//h3

    Click    xpath=//button[.//*[name()='svg' and contains(@class,'lucide-arrow-right')]]

    ${mudou}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    10s    500ms
    ...    PRIMEIRO CARD DE VENDA MUDOU    ${primeiro_nome_antes}

    RETURN    ${mudou}


PRIMEIRO CARD DE VENDA MUDOU
    [Arguments]    ${nome_anterior}

    AGUARDAR CARREGAMENTO DA LISTA DE VENDAS

    ${nome_atual}=    Get Text
    ...    xpath=(//div[contains(@class,'rounded-xl') and contains(@class,'bg-gray') and contains(@class,'max-w-[416px]')])[1]//h3

    Should Not Be Equal    ${nome_atual}    ${nome_anterior}


VALIDAR TODAS AS VENDAS
    [Documentation]    Percorre todas as páginas da lista "Minhas vendas",
    ...    validando formato dos dados de cada card e a existência no
    ...    Salesforce pelo número de instalação.
    ${continuar}=    Set Variable    ${True}

    WHILE    ${continuar}
        VALIDAR VENDAS DA PAGINA ATUAL
        ${continuar}=    NAVEGAR PARA PROXIMA PAGINA DE VENDAS
    END