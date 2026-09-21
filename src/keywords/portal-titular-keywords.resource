*** Settings ***
Documentation    Keywords do Portal do Titular (login, popup de indicação, dados cadastrais).
Library          Browser
Library          BuiltIn
Library          Collections
Library          String
Library          FakerLibrary    locale=pt_BR
Resource         salesforce-keywords.resource

*** Keywords ***
REALIZAR LOGIN PORTAL DO TITULAR
    [Arguments]    ${email}    ${password}

    # Indexado em [1]: o locator também casa com o botão "Entrar" do modal de
    # login (presente e oculto no DOM antes mesmo de o modal abrir), o que
    # viola o strict mode do Playwright se não for desambiguado.
    Wait For Elements State    (//*[contains(text(),'Entrar')])[1]    visible    10s
    Click    (//*[contains(text(),'Entrar')])[1]

    Wait For Elements State    //input[@type='email']    visible    10s
    Fill Text    //input[@type='email']    ${email}

    Wait For Elements State    //input[@type='password']    visible    10s
    Fill Secret    //input[@type='password']    $password

    Wait For Elements State    (//div[contains(text(),'Entrar')])[last()]    visible    10s
    Click    (//div[contains(text(),'Entrar')])[last()]

VALIDAR MENSAGEM DE ERRO DE LOGIN
    [Documentation]    Confirma a mensagem de erro exibida no formulário de login
    ...    (mesmas mensagens do app mobile: e-mail não cadastrado, senha incorreta
    ...    ou erro de conexão) e que o login realmente não foi concluído — a tela
    ...    de login continua visível.
    [Arguments]    ${mensagem_esperada}
    Wait For Elements State    //div[contains(@class,'text-error')]    visible    15s
    ${mensagem}=    Get Text    //div[contains(@class,'text-error')]
    Should Be Equal As Strings    ${mensagem}    ${mensagem_esperada}
    Wait For Elements State    (//div[contains(text(),'Entrar')])[last()]    visible    5s

DESATIVAR CONEXAO DE REDE
    [Documentation]    Simula perda de conexão bloqueando toda a rede do contexto
    ...    do navegador (equivalente a desativar wifi/dados no emulador mobile).
    Set Offline    True

REATIVAR CONEXAO DE REDE
    [Documentation]    Sempre chamado no teardown dos testes que desativam a rede —
    ...    mesmo se o teste falhar, o contexto não pode ficar offline para os
    ...    testes seguintes.
    Run Keyword And Ignore Error    Set Offline    False

PULAR ETAPA DE SALVAR ACESSO
    [Documentation]    A tela "Deseja salvar seus dados de acesso?" é condicional —
    ...    confirmado em execuções reais: apareceu em uma rodada e
    ...    não apareceu na rodada seguinte, para a mesma conta (provavelmente
    ...    depende de um estado já salvo na conta desde a primeira vez que se
    ...    clica em "Pular"/"Salvar"). Por isso esperamos por um tempo curto e
    ...    seguimos o fluxo normalmente se ela não aparecer.
    ${apareceu}=    Run Keyword And Return Status
    ...    Wait For Elements State    text=Deseja salvar seus dados de acesso?    visible    5s

    IF    ${apareceu}
        Click    (//div[contains(text(),'Pular')])[last()]
    END

SELECIONAR CPF OU CNPJ VINCULADO
    [Documentation]    Contas com mais de um CPF/CNPJ vinculado ao mesmo login
    ...    (comum em contas de expansão — fora de MG) mostram uma tela extra
    ...    "Com qual você deseja seguir?" depois do login. É condicional: contas
    ...    com um único vínculo (a maioria das testadas, todas de
    ...    MG) não mostram essa tela — confirmado. Por padrão
    ...    seleciona o primeiro CPF/CNPJ da lista; passe ${indice} (1 = primeiro)
    ...    para escolher outro.
    [Arguments]    ${indice}=1
    ${apareceu}=    Run Keyword And Return Status
    ...    Wait For Elements State    text=Com qual você deseja seguir?    visible    5s
    IF    ${apareceu}
        Click    (//div[contains(text(),'XXX.XXX')])[${indice}]
        Click    //div[text()='Confirmar']
        Wait For Elements State    text=Com qual você deseja seguir?    hidden    10s
    END

TROCAR PERFIL
    [Documentation]    Alterna para outro CPF/CNPJ vinculado à mesma conta
    ...    (recurso de contas de expansão com múltiplos vínculos — ver
    ...    SELECIONAR CPF OU CNPJ VINCULADO). Reabre a mesma tela de seleção.
    [Arguments]    ${indice}=1
    Click    //div[text()='Trocar Perfil']
    Wait For Elements State    text=Com qual você deseja seguir?    visible    10s
    Click    (//div[contains(text(),'XXX.XXX')])[${indice}]
    Click    //div[text()='Confirmar']
    Wait For Elements State    text=Com qual você deseja seguir?    hidden    10s

LOGIN NO PORTAL DO TITULAR
    [Documentation]    Fluxo comum a todos os testes: autentica, pula a tela de
    ...    "salvar dados de acesso" e resolve a seleção de CPF/CNPJ vinculado se
    ...    aparecer (contas com um único vínculo simplesmente não mostram essa
    ...    etapa). Usar como Test Setup da suíte, após ACESSAR PAGINA.
    [Arguments]    ${email}    ${password}
    REALIZAR LOGIN PORTAL DO TITULAR    ${email}    ${password}
    PULAR ETAPA DE SALVAR ACESSO
    SELECIONAR CPF OU CNPJ VINCULADO

ENCERRAR TESTE PORTAL DO TITULAR
    [Documentation]    Fecha todos os browsers ao final do teste, mesmo em caso de
    ...    falha. Usar como Test Teardown da suíte.
    Run Keyword And Ignore Error    Close Browser    ALL

VALIDAR BANNER INDICACAO
    [Documentation]    O convite para indicação deixou de ser um popup e hoje é um
    ...    banner fixo na home ("SUA INDICAÇÃO VALE PIX SEM LIMITES!"). O banner
    ...    inteiro (título + botão "Quero indicar") é UMA ÚNICA IMAGEM sem
    ...    alt/aria-label — confirmado via inspeção de DOM (nenhum
    ...    texto acessível "Quero indicar"/"regulamento" existe na página; há só
    ...    a <img src="...MainBanner/adimplente..."> com cursor:pointer). Por isso
    ...    a validação é pela presença da imagem, não por texto, e não há mais um
    ...    botão de "regulamento" separado para validar.
    Wait For Elements State    //img[contains(@src,'MainBanner')]    visible    10s

CLICAR NO BANNER INDICACAO
    [Documentation]    Clica no banner de indicação (imagem) e retorna a lista de
    ...    páginas abertas antes do clique, para validação por quem chamar (ver
    ...    NOVA PAGINA DEVE ESTAR ABERTA / VALIDAR MENSAGEM PADRAO DE INDICACAO).
    VALIDAR BANNER INDICACAO
    @{paginas_antes}=    Get Page Ids
    Click    //img[contains(@src,'MainBanner')]
    RETURN    ${paginas_antes}

NOVA PAGINA DEVE ESTAR ABERTA
    [Arguments]    ${paginas_antes}
    @{paginas_depois}=    Get Page Ids
    ${qtd_antes}=    Get Length    ${paginas_antes}
    ${qtd_depois}=    Get Length    ${paginas_depois}
    Should Be True    ${qtd_depois} > ${qtd_antes}    Nenhuma aba nova foi aberta.

URL DA PAGINA NAO DEVE ESTAR VAZIA
    [Documentation]    A aba nova pode existir (Get Page Ids) antes de terminar de
    ...    navegar para a URL de destino — Get Url retorna vazio nesse instante.
    ${url}=    Get Url
    Should Not Be Empty    ${url}

ACESSAR DADOS CADASTRAIS
    [Documentation]    Abre "Dados cadastrais" e expande o card do titular (o
    ...    primeiro da lista — confirmado que corresponde ao login
    ...    atual) para revelar os campos de e-mail/telefone.
    ...
    ...    NOTA: a tela deixou de mostrar o campo de e-mail direto — hoje é uma
    ...    lista de contatos, cada um colapsado por padrão, com um botão
    ...    "chevron" (div arredondado sem ícone/svg identificável, canto
    ...    superior direito do card) que expande/recolhe.
    ...
    ...    Locator "Perfil" com texto exato (não contains): em contas de
    ...    expansão, "Trocar Perfil" também contém a substring "Perfil".
    Wait For Elements State    //div[text()='Perfil']    visible    10s
    Click    //div[text()='Perfil']

    Wait For Elements State    //div[contains(text(),'Dados cadastrais')]    visible    10s
    Click    //div[contains(text(),'Dados cadastrais')]

    Wait For Elements State    (//input[@placeholder='Digite seu nome completo'])[1]    visible    10s
    Click    (//div[contains(@class,'rounded-full') and contains(@class,'right-4') and contains(@class,'top-4')])[1]
    Wait For Elements State    //input[@placeholder='Digite seu e-mail']    visible    10s

ALTERAR EMAIL DO TITULAR
    [Arguments]    ${novo_email}
    Wait For Elements State    //input[@placeholder='Digite seu e-mail']    visible    10s
    Click    //input[@placeholder='Digite seu e-mail']
    Keyboard Key    press    Control+a
    Keyboard Key    press    Backspace
    Fill Text    //input[@type='email']    ${novo_email}

CLICAR EM ATUALIZAR
    [Documentation]    Clica em "Atualizar", abrindo o modal de confirmação
    ...    "Tem certeza?". Isso acontece mesmo com e-mail em formato inválido —
    ...    confirmado via inspeção: a mensagem "Digite um e-mail
    ...    válido" só é exibida DEPOIS de confirmar em "Tem certeza?", nunca
    ...    antes. Portanto CONFIRMAR ATUALIZACAO é sempre necessário, tanto no
    ...    fluxo de sucesso quanto no de erro.
    Click    //div[contains(text(),'Atualizar')]

CONFIRMAR ATUALIZACAO
    Wait For Elements State    //div[contains(text(),'Tem certeza?')]    visible    10s
    Click    //div[contains(text(),'Tem certeza?')]

VALIDAR MENSAGEM DE SUCESSO NA ATUALIZACAO
    Wait For Elements State    //div[contains(text(),'Os dados foram atualizados com sucesso!')]    visible    10s
    Wait For Elements State    //div[contains(text(),'Entendi')]    visible    10s
    Click    //div[contains(text(),'Entendi')]

VALIDAR MENSAGEM DE ERRO NA ATUALIZACAO
    Wait For Elements State    //div[contains(text(),'Digite um e-mail válido')]    visible    10s
    Click    //div[contains(text(),'Cancelar')]

VALIDAR EMAIL DO TITULAR NO SALESFORCE
    [Documentation]
    ...    Confirma, via API, que o e-mail exibido como atualizado no portal
    ...    realmente persistiu no Contact do Salesforce localizado pelo CPF.
    ...
    ...    Encapsulado em "Wait Until Keyword Succeeds" porque a sincronização
    ...    portal -> Salesforce pode não ser instantânea; ajustar o timeout
    ...    abaixo (atualmente 20s/2s) conforme a latência real observada.
    ...
    ...    Assim como no Portal de Parceiros, pode existir mais de um Contact
    ...    para o mesmo CPF: considera-se validado se QUALQUER UM dos registros
    ...    retornados tiver o e-mail esperado.
    [Arguments]    ${cpf}    ${email_esperado}

    Wait Until Keyword Succeeds    20s    2s
    ...    EMAIL DO TITULAR DEVE CONFERIR NO SALESFORCE    ${cpf}    ${email_esperado}

EMAIL DO TITULAR DEVE CONFERIR NO SALESFORCE
    [Arguments]    ${cpf}    ${email_esperado}

    @{contatos}=    BUSCAR CONTATO POR CPF    ${cpf}

    ${encontrado}=    Set Variable    ${False}
    @{emails_encontrados}=    Create List

    FOR    ${contato}    IN    @{contatos}
        ${email_salesforce}=    Set Variable    ${contato}[Email]
        Append To List    ${emails_encontrados}    ${email_salesforce}

        ${confere}=    Run Keyword And Return Status
        ...    Should Be Equal As Strings
        ...    ${email_esperado}
        ...    ${email_salesforce}
        ...    ignore_case=True

        IF    ${confere}
            ${encontrado}=    Set Variable    ${True}
            BREAK
        END
    END

    Should Be True    ${encontrado}
    ...    E-mail não confere no Salesforce. Esperado "${email_esperado}", encontrado: ${emails_encontrados}

    Log To Console    ✓ E-mail validado no Salesforce: ${email_esperado}

GERAR EMAIL DE TESTE
    [Documentation]    Gera um e-mail fake (via Faker) para usar como "novo e-mail"
    ...    no teste de atualização com sucesso, evitando reutilizar sempre o
    ...    mesmo valor entre execuções.
    ${email}=    FakerLibrary.Email
    RETURN    ${email}

GERAR EMAIL INVALIDO DE TESTE
    [Documentation]    Gera um e-mail sintaticamente inválido (sem "@") a partir de
    ...    um e-mail fake, para o teste de rejeição de formato inválido.
    ${email_base}=    FakerLibrary.Email
    ${email_invalido}=    Replace String    ${email_base}    @    ${EMPTY}
    RETURN    ${email_invalido}

VALIDAR MENSAGEM PADRAO DE INDICACAO
    [Documentation]    Confirma que uma aba nova foi aberta com o link de
    ...    compartilhamento padrão via WhatsApp (api.whatsapp.com/send?text=...),
    ...    com a mesma mensagem fixa usada no app mobile (mesmo backend).
    ...    O PIN do cliente é dinâmico (varia por conta), então validamos o
    ...    padrão da URL em vez de um valor fixo. Fecha a aba nova ao final e
    ...    volta para a página original.
    [Arguments]    ${paginas_antes}
    Wait Until Keyword Succeeds    5s    500ms    NOVA PAGINA DEVE ESTAR ABERTA    ${paginas_antes}
    Switch Page    NEW
    Wait Until Keyword Succeeds    5s    500ms    URL DA PAGINA NAO DEVE ESTAR VAZIA
    ${url}=    Get Url
    # NOTA: a URL final varia conforme a rota — ex.: clicar direto no
    # banner leva à URL "crua" (.../send?text=...), enquanto outros caminhos podem
    # passar pelo redirect do próprio WhatsApp (.../send/?text=...&type=custom_url...,
    # com "+" no lugar de "%20" e parâmetros extras). Por isso validamos só o host+path
    # e extraímos o parâmetro "text" via parse_qs (tolerante à ordem/formatação),
    # em vez de casar a URL inteira ou fatiar a string manualmente.
    Should Contain    ${url}    api.whatsapp.com/send
    ${query}=    Evaluate    urllib.parse.urlparse('''${url}''').query    modules=urllib.parse
    ${params}=    Evaluate    urllib.parse.parse_qs('''${query}''')    modules=urllib.parse
    ${mensagem}=    Evaluate    $params['text'][0]
    Should Contain    ${mensagem}    Ei, quero te indicar algo que tem me ajudado muito
    Should Contain    ${mensagem}    economizando todo mês na conta de luz com a Lumen Energia
    Should Contain    ${mensagem}    É super simples, tudo online, não precisa instalar nada e nenhum investimento
    Should Contain    ${mensagem}    Descubra o quanto você pode economizar
    Should Match Regexp    ${mensagem}    https://cloud\\.economia\\.lumenenergia\\.com\\.br/lumenmaiscontratacaocogni2/\\?pin=\\S+
    Close Page
    Switch Page    ${paginas_antes}[0]

# ---------------------------------------------------------------------------
# Perfil / Instalação
# ---------------------------------------------------------------------------

ABRIR MENU DE PERFIL
    [Documentation]    Locator com texto exato ("Perfil", não contains) —
    ...    confirmado: em contas de expansão com múltiplos
    ...    CPF/CNPJ, o botão "Trocar Perfil" também aparece no cabeçalho e
    ...    "contains(text(),'Perfil')" vira ambíguo (strict mode do Playwright).
    Wait For Elements State    //div[text()='Perfil']    visible    10s
    Click    //div[text()='Perfil']

IR PARA RENOMEAR INSTALACAO
    [Documentation]    Indexado em [1]: contas de expansão podem ter várias
    ...    instalações listadas nessa tela (ver OBTER NUMERO DA INSTALACAO).
    Wait For Elements State    //div[contains(text(),'Renomear instala')]    visible    10s
    Click    //div[contains(text(),'Renomear instala')]
    Wait For Elements State    (//div[starts-with(text(),'Instalação ')])[1]    visible    10s

OBTER NUMERO DA INSTALACAO
    [Documentation]    Retorna o número da PRIMEIRA instalação da lista. Contas de
    ...    expansão podem ter várias instalações vinculadas ao mesmo perfil
    ...    (confirmado: uma conta de teste tinha 6) — diferente de
    ...    MG, onde as contas testadas até aqui têm só uma.
    ${texto}=    Get Text    (//div[starts-with(text(),'Instalação ')])[1]
    ${numero}=    Evaluate    '''${texto}'''.replace('Instalação ', '').strip()
    RETURN    ${numero}

VOLTAR
    [Documentation]    Clica no link/botão "Voltar" da tela atual (navegação
    ...    interna do SPA). NÃO usar "Go Back" do navegador nem "Go To" com a URL
    ...    base — confirmado que ambos quebram a sessão (o app não
    ...    usa a History API do navegador para essas transições internas).
    Click    (//div[contains(text(),'Voltar')])[last()]

# ---------------------------------------------------------------------------
# Fatura / 2ª via
# ---------------------------------------------------------------------------

ABRIR POPUP SEGUNDA VIA
    Wait For Elements State    //div[contains(text(),'Gerar 2') and contains(text(),'via da fatura')]    visible    10s
    Click    //div[contains(text(),'Gerar 2') and contains(text(),'via da fatura')]
    Wait For Elements State    text=2ª Via da Conta Lumen    visible    10s

VALIDAR ESTADO INICIAL DO POPUP SEGUNDA VIA
    [Documentation]    O botão "Gerar 2ª via da fatura" do popup começa desabilitado
    ...    até que Ano e Mês sejam escolhidos (mesmo comportamento do app mobile).
    Get Element States    (//div[contains(text(),'Gerar 2ª via da fatura')])[last()]    contains    disabled

SELECIONAR ANO SEGUNDA VIA
    [Arguments]    ${ano}
    Click    //div[text()='Ano']
    Wait For Elements State    //div[text()='${ano}']    visible    5s
    Click    //div[text()='${ano}']

SELECIONAR MES SEGUNDA VIA
    [Arguments]    ${mes}
    Click    //div[text()='Mês']
    Wait For Elements State    //div[text()='${mes}']    visible    5s
    Click    //div[text()='${mes}']

VALIDAR BOTAO GERAR HABILITADO
    Get Element States    (//div[contains(text(),'Gerar 2ª via da fatura')])[last()]    contains    enabled

CLICAR EM GERAR SEGUNDA VIA
    Click    (//div[contains(text(),'Gerar 2ª via da fatura')])[last()]
    Wait For Elements State    //div[contains(text(),'Pagamento da conta')]    visible    15s

VALIDAR ABA PAGAMENTO
    [Documentation]    Valida os dados da aba "Pagamento" da 2ª via gerada e retorna
    ...    um dicionário com os valores (para eventual comparação com o Salesforce).
    ...
    ...    NOTA: o texto "${mes}/${ano}" é renderizado como 3 text
    ...    nodes separados ("Junho", "/", "2026") — XPath text() nunca casa com
    ...    isso, só o motor de texto do Playwright (locator "text="). Além disso
    ...    o card de pagamento fica sobreposto ao conteúdo da home no DOM (ambos
    ...    presentes ao mesmo tempo), então extrair valores por XPath posicional
    ...    arrisca pegar o card errado (ex.: "economia total" da home em vez da
    ...    "economia este mês" do card). Por isso os valores são extraídos via
    ...    innerText do menor ancestral que contém título+Vencimento+economia,
    ...    em vez de XPath sibling/ancestor.
    [Arguments]    ${mes}    ${ano}
    # Aspas no locator "text=" força match exato (não substring) — sem elas,
    # esse locator também batia num parágrafo não relacionado que contém
    # "pagamento da conta" como parte do texto ("strict mode violation").
    Wait For Elements State    text="Pagamento da conta"    visible    10s
    Wait For Elements State    text=${mes}/${ano}    visible    10s

    ${texto_card}=    Evaluate JavaScript    ${None}    (() => {
    ...    var titulo = Array.from(document.querySelectorAll('div')).find(function(d){
    ...    return d.children.length === 0 && (d.innerText || '').trim() === 'Pagamento da conta';
    ...    });
    ...    if (!titulo) return '';
    ...    var atual = titulo;
    ...    for (var i = 0; i < 10 && atual; i++) {
    ...    var txt = atual.innerText || '';
    ...    if (txt.indexOf('Vencimento') !== -1 && txt.toLowerCase().indexOf('economia este') !== -1) {
    ...    return txt;
    ...    }
    ...    atual = atual.parentElement;
    ...    }
    ...    return '';
    ...    })()
    Should Not Be Empty    ${texto_card}    Não foi possível localizar o card de pagamento na página.

    # "Em aberto" adicionado — status real observado na conta
    # de teste atual, além dos 3 já previstos (Pago/Pendente/Vencido).
    Should Match Regexp    ${texto_card}    (?i)\\bPago\\b|Pendente|Vencid|Em aberto
    ${status}=    Evaluate    re.search(r'(?i)Pago|Pendente|Vencid\\w*|Em aberto', '''${texto_card}''').group(0)    modules=re

    ${valor}=    Evaluate    re.search(r'R\\$\\s?[\\d.]+,\\d{2}', '''${texto_card}'''.split('Vencimento')[0]).group(0)    modules=re

    ${vencimento}=    Evaluate    re.search(r'Vencimento:\\s?(\\d{2}/\\d{2}/\\d{4})', '''${texto_card}''').group(1)    modules=re

    ${economia}=    Evaluate    re.search(r'Sua economia este mês é (R\\$\\s?[\\d.]+,\\d{2})', '''${texto_card}''').group(1)    modules=re

    &{dados}=    Create Dictionary
    ...    mes_ano=${mes}/${ano}    valor=${valor}    status=${status}
    ...    vencimento=${vencimento}    economia=${economia}
    RETURN    &{dados}

IR PARA ABA CONSUMO
    [Documentation]    NOTA: a aba "Consumo" ficou travada num spinner
    ...    infinito nas execuções manuais contra homologação, mesmo aguardando
    ...    10s+ — pode ser um problema real do ambiente/conta de teste, não do
    ...    locator. Por isso esta keyword só confirma a navegação (o título
    ...    aparece); não valida os valores exibidos. Investigar antes de
    ...    fortalecer esta validação.
    Click    //div[text()='Consumo']
    Wait For Elements State    //div[text()='Descrição do consumo']    visible    10s

# ---------------------------------------------------------------------------
# Contas (aba inferior)
# ---------------------------------------------------------------------------

IR PARA ABA CONTAS
    Wait For Elements State    //div[text()='Contas']    visible    10s
    Click    //div[text()='Contas']
    Wait For Elements State    //div[contains(text(),'unificada')]    visible    10s

OBTER TEXTO DO BANNER DE UNIFICACAO
    ${texto}=    Get Text    //div[contains(text(),'unificada')]
    RETURN    ${texto}

CONTA EM ABERTO EXISTE
    [Documentation]    Retorna False sem falhar quando não há conta em aberto —
    ...    usado para pular graciosamente os testes de pagamento/encaminhamento
    ...    quando o estado atual da conta de teste não tem fatura pendente.
    ${sem_conta}=    Run Keyword And Return Status
    ...    Wait For Elements State    text=Nenhuma conta em aberto encontrada    visible    5s
    ${existe}=    Evaluate    not ${sem_conta}
    RETURN    ${existe}

CLICAR EM PAGAR CONTA
    # [1] porque pode haver mais de uma conta em aberto ao mesmo tempo (cada
    # uma com seu próprio botão "Pagar conta") — sem indexação, o locator
    # bate em mais de um elemento e o Playwright falha em modo estrito.
    Wait For Elements State    (//div[text()='Pagar conta'])[1]    visible    10s
    Click    (//div[text()='Pagar conta'])[1]
    Wait For Elements State    text=Escolha a forma de pagamento:    visible    10s

VALIDAR OPCOES DE PAGAMENTO DISPONIVEIS
    [Documentation]    Confirma as 3 opções de pagamento da conta em aberto —
    ...    mesmas opções e mesmos nomes do app mobile (Pix copia e cola, Código
    ...    de barras, Pix QR code). "Pix copia e cola" e "Código de barras" só
    ...    copiam para a área de transferência (sem mudança visual na tela) —
    ...    por isso só validamos que estão habilitadas, sem tentar ler o
    ...    clipboard.
    Wait For Elements State    //div[text()='Pix copia e cola']    visible    10s
    Get Element States    //div[text()='Pix copia e cola']    contains    enabled
    Wait For Elements State    //div[text()='Código de barras']    visible    5s
    Get Element States    //div[text()='Código de barras']    contains    enabled
    Wait For Elements State    //div[text()='Pix QR code']    visible    5s
    Get Element States    //div[text()='Pix QR code']    contains    enabled

ABRIR PIX QR CODE
    Click    //div[text()='Pix QR code']
    Wait For Elements State    text=Realize o pagamento    visible    10s

FECHAR MODAL QR CODE
    [Documentation]    Fecha com ESC — assim como os outros modais deste app,
    ...    não há um "X" com locator estável (nenhum <svg> identificável perto do
    ...    modal, confirmado). Não há input focado aqui, então,
    ...    diferente do modal "Indique um amigo", ESC funciona direto.
    Keyboard Key    press    Escape
    Wait For Elements State    text=Realize o pagamento    hidden    10s

BAIXAR CONTA LUMEN
    [Documentation]    Clica em "Baixar conta" (card de conta em aberto ou item do
    ...    histórico) e confirma que um PDF de verdade foi baixado, no padrão
    ...    "Conta Lumen-<Mês>-<Ano>.pdf" — mesmo padrão de nome já usado no app
    ...    mobile para o arquivo compartilhado.
    ...
    ...    NOTA: o timeout padrão (10s) não é sempre suficiente —
    ...    a geração do PDF no servidor pode demorar mais que isso. O timeout
    ...    que estoura aqui é o de esperar o evento "download" COMEÇAR (não o
    ...    de "download_timeout", que só vale para esperar ele TERMINAR) —
    ...    por isso o ajuste é via "Set Browser Timeout" (escopo Test, volta
    ...    ao normal sozinho no fim do teste), não via argumento da keyword.
    Set Browser Timeout    30s    scope=Test
    ${promise}=    Promise To Wait For Download    download_timeout=30s
    Click    (//div[text()='Baixar conta'])[1]
    Wait For All Promises
    ${info}=    Evaluate    $promise.result()
    Should Be Equal As Strings    ${info}[state]    finished
    Should Match Regexp    ${info}[suggestedFilename]    ^Conta Lumen-\\w+-\\d{4}\\.pdf$
    RETURN    ${info}[suggestedFilename]

OBTER NOME DA DISTRIBUIDORA
    [Documentation]    Lê o nome da distribuidora exibido no link "Visualizar
    ...    conta da <distribuidora>" da conta em aberto, em vez de fixar um nome —
    ...    varia por região (ex.: ENERNORTE RN, EnerDist, etc.).
    ...
    ...    NOTA: buscar por "qualquer elemento com classe underline"
    ...    é ambíguo — o botão "Trocar Perfil" do cabeçalho também usa essa
    ...    classe e aparecia primeiro no DOM. Por isso ancoramos no rótulo
    ...    "Visualizar conta da" e pegamos o irmão seguinte, não a classe CSS.
    ${nome}=    Evaluate JavaScript    ${None}    (() => {
    ...    var label = Array.from(document.querySelectorAll('div')).find(function(d){
    ...    return d.children.length === 0 && /Visualizar\\s*conta\\s*da/i.test(d.innerText || '');
    ...    });
    ...    if (!label || !label.nextElementSibling) return '';
    ...    return label.nextElementSibling.innerText.trim();
    ...    })()
    Should Not Be Empty    ${nome}    Não encontrei o nome da distribuidora na tela — a conta em aberto tem conta separada da distribuidora?
    RETURN    ${nome}

VALIDAR AVISO DE NAO PAGAR DISTRIBUIDORA
    [Documentation]    Confirma o aviso exibido no modal de pagamento em contas
    ...    unificadas fora de MG: pagar a fatura da Lumen já inclui o valor da
    ...    distribuidora, então pagar as duas geraria duplicidade. Esse aviso é
    ...    específico de contas de expansão com conta da distribuidora separada.
    Wait For Elements State    //div[contains(text(),'Não pague a conta da distribuidora')]    visible    10s

BAIXAR CONTA DA DISTRIBUIDORA
    [Documentation]    Clica em "Visualizar conta da <distribuidora>" (só existe em
    ...    contas não unificadas/parcialmente unificadas fora de MG, onde a
    ...    distribuidora local emite conta separada da Lumen) e confirma que um
    ...    PDF de verdade foi baixado ("Fatura Distribuidora.pdf"). O nome da
    ...    distribuidora varia por região (ex.: ENERNORTE RN) —
    ...    por isso é parametrizado, não fixo.
    [Arguments]    ${nome_distribuidora}
    ${promise}=    Promise To Wait For Download
    Click    //*[contains(text(),'${nome_distribuidora}')]
    Wait For All Promises
    ${info}=    Evaluate    $promise.result()
    Should Be Equal As Strings    ${info}[state]    finished
    Should Contain    ${info}[suggestedFilename]    Fatura Distribuidora
    RETURN    ${info}[suggestedFilename]

IR PARA HISTORICO COMPLETO DE CONTAS
    Wait For Elements State    //div[contains(text(),'Ver hist') and contains(text(),'rico completo de contas')]    visible    10s
    Click    //div[contains(text(),'Ver hist') and contains(text(),'rico completo de contas')]
    Wait For Elements State    //div[contains(text(),'Histórico completo de contas')]    visible    10s

VALIDAR LISTA DE HISTORICO DE CONTAS
    [Documentation]    Cada conta do histórico tem um botão "Baixar conta" (web usa
    ...    download em vez do compartilhamento nativo do mobile); validamos que a
    ...    lista tem mais de uma conta, sem fixar a quantidade exata.
    ${qtd_contas}=    Get Element Count    //div[contains(text(),'Baixar conta')]
    Should Be True    ${qtd_contas} >= 2    Esperava pelo menos 2 contas no histórico, encontrado ${qtd_contas}.

# ---------------------------------------------------------------------------
# Indicação (aba inferior)
# ---------------------------------------------------------------------------

IR PARA ABA INDICACAO
    Wait For Elements State    //div[text()='Indicação']    visible    10s
    Click    //div[text()='Indicação']
    Wait For Elements State    //div[text()='Indicar amigo']    visible    10s

ABRIR FORMULARIO INDICAR AMIGO
    Click    //div[text()='Indicar amigo']
    Wait For Elements State    //div[text()='Indicar']    visible    10s

VALIDAR BOTAO INDICAR DESABILITADO
    Get Element States    //div[text()='Indicar']    contains    disabled

PREENCHER FORMULARIO INDICAR AMIGO
    [Arguments]    ${nome}    ${telefone}
    Fill Text    //input[@placeholder='Insira aqui o nome']    ${nome}
    Fill Text    //input[@placeholder='Insira aqui o telefone']    ${telefone}

VALIDAR TELEFONE COM MASCARA APLICADA
    ${valor}=    Get Text    //input[@placeholder='Insira aqui o telefone']
    Should Match Regexp    ${valor}    ^\\(\\d{2}\\) \\d{4,5}-\\d{4}$

VALIDAR BOTAO INDICAR HABILITADO
    Get Element States    //div[text()='Indicar']    contains    enabled

VALIDAR ERRO DE TELEFONE INVALIDO
    Wait For Elements State    //div[contains(text(),'Telefone deve ter pelo menos 10 dígitos')]    visible    10s
    Get Element States    //div[text()='Indicar']    contains    disabled

FECHAR FORMULARIO SEM ENVIAR
    [Documentation]    Não clicamos em "Indicar": isso enviaria um convite real.
    ...    Fecha com ESC (confirmado: o "X" do modal não é um
    ...    elemento com locator estável — nenhum <svg> próximo ao modal). Antes
    ...    do ESC, clica num texto neutro do modal para tirar o foco do campo de
    ...    telefone — com o input focado, o ESC não fecha o modal (o evento é
    ...    consumido pelo campo, não propaga).
    Click    //div[text()='Preencha os campos abaixo:']
    Sleep    500ms
    Keyboard Key    press    Escape
    Wait For Elements State    //div[text()='Indicar']    hidden    10s

CLICAR EM COMPARTILHAR INDICACAO
    Wait For Elements State    //div[text()='Compartilhar']    visible    10s
    Click    //div[text()='Compartilhar']

ABRIR COMO FUNCIONA INDICACAO
    Wait For Elements State    //div[contains(text(),'Como funciona')]    visible    10s
    Click    //div[contains(text(),'Como funciona')]
    Wait For Elements State    text=Dúvidas sobre o indique e ganhe    visible    10s

IR PARA ALTERAR CHAVE PIX
    [Documentation]    Apenas navega até a tela — NÃO altera nem submete nenhum
    ...    dado, pois a tela envolve dados bancários reais da conta de teste.
    Wait For Elements State    //div[contains(text(),'Alterar chave pix')]    visible    10s
    Click    //div[contains(text(),'Alterar chave pix')]
    Wait For Elements State    text=Cadastro chave Pix    visible    10s
