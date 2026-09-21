*** Settings ***
Documentation    Keywords do cadastro Radar (empresas parceiras que vendem o
...              produto Lumen e recebem retorno financeiro). Cobre os dois
...              caminhos de cadastro:
...              - Deslogado: https://parceiro-dev.lumenenergia.com.br/register-radar-forms/
...              - Logado (dentro do Portal dos Parceiros): .../register-radar/
...              Os dois usam exatamente o mesmo formulário de 3 etapas
...              (Empresa -> Endereço -> Financeiro) e submetem para o mesmo
...              endpoint (POST /api/v1/Radar/Register). A única diferença de
...              tela é que o caminho logado tem um botão extra "Abrir lista
...              de CNAE's disponíveis".
Library          Browser
Library          BuiltIn
Library          Collections
Resource         salesforce-keywords.resource

*** Keywords ***
IR PARA CADASTRO RADAR DESLOGADO
    ACESSAR PAGINA https://parceiro-dev.lumenenergia.com.br/register-radar-forms/
    Wait For Elements State    //input[@placeholder='Nome da empresa']    visible    10s

IR PARA CADASTRO RADAR LOGADO
    [Documentation]    Requer login prévio no Portal dos Parceiros (ver
    ...    REALIZAR LOGIN PORTAL DOS PARCEIROS).
    ...
    ...    NOTA: navegar direto para esta URL (via "Go To") logo
    ...    após o login pode redirecionar de volta para a tela de login — não
    ...    é um bug do produto, é uma condição de corrida: o token de sessão
    ...    (localStorage, chave "token") ainda não tinha sido gravado no
    ...    instante da navegação. Por isso esperamos o token existir antes de
    ...    navegar, em vez de um Sleep fixo.
    Wait Until Keyword Succeeds    10s    500ms    TOKEN DE SESSAO DEVE EXISTIR
    Go To    https://parceiro-dev.lumenenergia.com.br/register-radar/
    Wait For Elements State    text=Registrar Radar    visible    10s

TOKEN DE SESSAO DEVE EXISTIR
    ${tem_token}=    Evaluate JavaScript    ${None}    (() => localStorage.getItem('token') !== null)()
    Should Be True    ${tem_token}    Token de sessão ainda não foi gravado no localStorage.

PREENCHER ETAPA EMPRESA RADAR
    [Arguments]
    ...    ${nome_empresa}    ${razao_social}    ${cnpj}    ${tipo_empresa}
    ...    ${nome_responsavel}    ${documento_responsavel}    ${telefone_responsavel}    ${email_responsavel}
    Wait For Elements State    //input[@placeholder='Nome da empresa']    visible    10s
    Fill Text    //input[@placeholder='Nome da empresa']    ${nome_empresa}
    Fill Text    //input[@placeholder='Razão Social']    ${razao_social}
    Fill Text    //input[@placeholder='CNPJ']    ${cnpj}

    Click    //input[@placeholder='Tipo de empresa']
    Wait For Elements State    //div[text()='${tipo_empresa}']    visible    5s
    Click    //div[text()='${tipo_empresa}']

    Fill Text    //input[@placeholder='Nome do responsável']    ${nome_responsavel}
    Fill Text    //input[@placeholder='Documento do responsável']    ${documento_responsavel}
    Fill Text    //input[@placeholder='Telefone do responsável']    ${telefone_responsavel}
    Fill Text    //input[@placeholder='E-mail do responsável']    ${email_responsavel}

AVANCAR CADASTRO RADAR
    Click    //span[text()='Avançar']

VALIDAR AVANCAR DESABILITADO
    Get Element States    //span[text()='Avançar']    contains    disabled

VALIDAR AVANCAR HABILITADO
    Get Element States    //span[text()='Avançar']    contains    enabled

VALIDAR FINALIZAR CADASTRO DESABILITADO
    Get Element States    //span[text()='Finalizar Cadastro']    contains    disabled

VALIDAR FINALIZAR CADASTRO HABILITADO
    Get Element States    //span[text()='Finalizar Cadastro']    contains    enabled

VALIDAR MENSAGEM DE VALIDACAO RADAR
    [Documentation]    Confirma uma mensagem de validação de campo (ex.: "CNPJ
    ...    inválido.", "E-mail inválido."). Algumas aparecem como toast e podem
    ...    sumir sozinhas depois de alguns segundos — por isso o timeout é
    ...    curto e a chamada deve vir logo após a ação que dispara a mensagem,
    ...    sem Sleep antes.
    [Arguments]    ${mensagem}
    Wait For Elements State    //*[contains(text(),'${mensagem}')]    visible    5s

FECHAR E REABRIR CADASTRO RADAR
    [Documentation]    Fecha a aba atual e abre uma nova na mesma URL, dentro do
    ...    mesmo contexto do navegador (mesma origem = mesmo localStorage,
    ...    exatamente como fechar/reabrir uma aba de verdade no mesmo
    ...    navegador). O formulário salva o progresso na chave
    ...    "partnerRegisterState" do localStorage — tanto os valores já
    ...    preenchidos quanto a etapa em que o usuário parou devem continuar lá.
    [Arguments]    ${url}
    Close Page
    New Page    ${url}
    Wait For Load State    domcontentloaded

VOLTAR ETAPA RADAR
    # contains(., ...) em vez de contains(text(), ...): o texto do botão vem
    # quebrado em mais de um text node — ver nota em ANEXAR DOCUMENTOS RADAR
    # e no teste de persistência de localStorage.
    Click    //button[contains(.,'Voltar')]

ANEXAR DOCUMENTOS RADAR
    [Documentation]    Anexa Cartão CNPJ e Documento de Identificação. A tela só
    ...    valida o formato do arquivo (PDF/JPG/PNG), não o conteúdo — por isso
    ...    reaproveitamos um template já existente no projeto para os dois.
    Wait For Elements State    (//input[@type='file'])[1]    attached    10s
    Upload File By Selector    (//input[@type='file'])[1]    src/templates/rg-frente.png
    Upload File By Selector    (//input[@type='file'])[2]    src/templates/rg-frente.png

PREENCHER ETAPA ENDERECO RADAR
    [Documentation]    O CEP preenche Logradouro/Bairro/Cidade/Estado
    ...    automaticamente (consulta real) — só é preciso informar Número e,
    ...    opcionalmente, Complemento.
    [Arguments]    ${cep}    ${numero}    ${complemento}=${EMPTY}
    Wait For Elements State    //input[@placeholder='CEP']    visible    10s
    Fill Text    //input[@placeholder='CEP']    ${cep}
    Wait For Elements State    //input[@placeholder='Cidade']    visible    5s

    Fill Text    //input[@placeholder='Número']    ${numero}
    IF    '''${complemento}''' != ''
        Fill Text    //input[@placeholder='Complemento']    ${complemento}
    END

PREENCHER ETAPA FINANCEIRO RADAR
    [Arguments]    ${banco}    ${agencia}    ${conta}    ${chave_pix}
    Wait For Elements State    //input[@placeholder='Banco']    visible    10s
    Fill Text    //input[@placeholder='Banco']    ${banco}
    Fill Text    //input[@placeholder='Agência']    ${agencia}
    Fill Text    //input[@placeholder='Conta']    ${conta}
    Fill Text    //input[@placeholder='Chave Pix']    ${chave_pix}

FINALIZAR CADASTRO RADAR
    [Documentation]    Clica em "Finalizar Cadastro" e retorna a resposta da API
    ...    (POST /api/v1/Radar/Register) como um dicionário Robot Framework
    ...    (status/body/etc.) — é a fonte de verdade pra saber se o cadastro
    ...    funcionou, independente de feedback visual (ver nota abaixo). Em
    ...    caso de erro de duplicidade a tela mostra um banner normalmente (ver
    ...    VALIDAR ERRO DE CADASTRO DUPLICADO) nos dois caminhos.
    ...
    ...    Em caso de SUCESSO o comportamento visual DIFERE entre os dois
    ...    caminhos — confirmado:
    ...    - Deslogado: NÃO dá nenhum feedback (só reseta o formulário em
    ...      silêncio, mesmo esperando 10s) — usar VALIDAR CADASTRO RADAR
    ...      CRIADO NO SALESFORCE como confirmação.
    ...    - Logado: redireciona (client-side, ~2s de atraso — esperar antes de
    ...      checar) para /radar-register-completed/, mostrando "Acesso
    ...      disponível após assinatura" — ver VALIDAR TELA DE CADASTRO RADAR
    ...      CONCLUIDO.
    ${promise}=    Promise To    Wait For Response
    ...    matcher=response => response.url().includes('Radar/Register')    timeout=15s
    Click    //span[text()='Finalizar Cadastro']
    Wait For All Promises
    ${resposta}=    Evaluate    $promise.result()
    RETURN    ${resposta}

VALIDAR ERRO DE CADASTRO DUPLICADO
    Wait For Elements State    text=Dados já pertencentes a um contato Radar.    visible    10s

VALIDAR TELA DE CADASTRO RADAR CONCLUIDO
    [Documentation]    Só existe no caminho LOGADO. Depois de FINALIZAR
    ...    CADASTRO RADAR com sucesso, a tela redireciona (client-side, ~2s de
    ...    atraso) para /radar-register-completed/, mostrando o nome do
    ...    responsável logado e avisando que o login/senha do novo parceiro só
    ...    serão enviados após a assinatura do termo pela pessoa indicada.
    Wait For Elements State    //h1[contains(text(),'Acesso disponível após assinatura')]    visible    10s
    ${url}=    Get Url
    Should Contain    ${url}    /radar-register-completed/

VALIDAR CADASTRO RADAR CRIADO NO SALESFORCE
    [Documentation]    Confirma via Salesforce que o Account (empresa) e o
    ...    Contact (responsável) foram criados corretamente — necessário porque
    ...    a tela não dá nenhuma confirmação visual de sucesso (ver
    ...    FINALIZAR CADASTRO RADAR).
    [Arguments]
    ...    ${account_id}    ${contact_id}    ${nome_empresa}    ${cnpj}
    ...    ${nome_responsavel}    ${documento_responsavel}    ${email_responsavel}

    ${cnpj_sem_formatacao}=    Evaluate
    ...    '''${cnpj}'''.replace('.', '').replace('/', '').replace('-', '')
    ${doc_sem_formatacao}=    Evaluate
    ...    '''${documento_responsavel}'''.replace('.', '').replace('-', '')

    ${res_conta}=    EXECUTAR SOQL
    ...    SELECT Id, Name, CPFCNPJSemFormataco__c FROM Account WHERE Id = '${account_id}'
    Should Be True    ${res_conta}[totalSize] > 0
    ...    Account ${account_id} não encontrada no Salesforce.
    ${conta}=    Set Variable    ${res_conta}[records][0]
    Should Be Equal As Strings    ${conta}[Name]    ${nome_empresa}    ignore_case=True
    Should Be Equal As Strings    ${conta}[CPFCNPJSemFormataco__c]    ${cnpj_sem_formatacao}

    ${res_contato}=    EXECUTAR SOQL
    ...    SELECT Id, Name, Email, CPFCNPJSemFormataco__c FROM Contact WHERE Id = '${contact_id}'
    Should Be True    ${res_contato}[totalSize] > 0
    ...    Contact ${contact_id} não encontrado no Salesforce.
    ${contato}=    Set Variable    ${res_contato}[records][0]
    Should Be Equal As Strings    ${contato}[Name]    ${nome_responsavel}    ignore_case=True
    Should Be Equal As Strings    ${contato}[Email]    ${email_responsavel}    ignore_case=True
    Should Be Equal As Strings    ${contato}[CPFCNPJSemFormataco__c]    ${doc_sem_formatacao}

    Log To Console
    ...    ✓ Cadastro Radar confirmado no Salesforce: Account "${nome_empresa}" + Contact "${nome_responsavel}"

# ---------------------------------------------------------------------------
# Lista de CNAE's disponíveis (só existe no caminho logado)
# ---------------------------------------------------------------------------

ABRIR LISTA DE CNAES DISPONIVEIS
    # 20s: a lista de CNAE's às vezes demora mais que 10s pra carregar/renderizar
    # por completo (mesmo padrão de lentidão já visto em outras telas do projeto).
    Wait For Elements State    //button[contains(text(),'CNAE')]    visible    10s
    Click    //button[contains(text(),'CNAE')]
    # Locator evita o apóstrofo de "CNAE's": confirmado que a tela
    # usa apóstrofo curvo (’, U+2019), não o reto (') — "Confira os CNAE" sozinho
    # já é único (só o título do modal começa assim; o botão que abre começa com
    # "Abrir").
    Wait For Elements State    //*[contains(text(),'Confira os CNAE')]    visible    20s

BUSCAR CNAE
    [Arguments]    ${termo}
    Fill Text    //input[@placeholder='Pesquisar um código ou atividade de CNAE']    ${termo}

CONTAR LINHAS DA LISTA DE CNAES
    ${qtd}=    Get Element Count    //table//tr
    RETURN    ${qtd}

FECHAR LISTA DE CNAES
    Click    //span[text()='Close']
    Wait For Elements State    //*[contains(text(),'Confira os CNAE')]    hidden    5s
