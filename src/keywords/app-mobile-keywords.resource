*** Settings ***
Documentation        Keywords do app mobile Lumen Energia (Portal do Cliente),
...                  via Appium/UiAutomator2.
Library        AppiumLibrary
Library        Collections
Library        Process


*** Variables ***
${PERMISSAO_NOTIFICACAO_ALLOW}    id=com.android.permissioncontroller:id/permission_allow_button
${BTN_ENTRAR_BOASVINDAS}          accessibility_id=Entrar
${CAMPO_EMAIL}                    xpath=//android.widget.EditText[@password="false"]
${CAMPO_SENHA}                    xpath=//android.widget.EditText[@password="true"]
${BTN_ENTRAR_LOGIN}               accessibility_id=Entrar
${BTN_ESQUECI_SENHA}              accessibility_id=Esqueci minha senha
${BTN_PULAR}                      accessibility_id=Pular
${BTN_INICIO_HOME}                accessibility_id=Início
# Mensagem de erro (email não cadastrado OU credenciais inválidas) aparece
# sempre como o TextView logo após o campo de senha.
${TXT_ERRO_LOGIN}                 xpath=//android.widget.EditText[@password="true"]/following-sibling::android.widget.TextView[1]

# Banner de indicação: imagem clicável sem texto/id acessível; localizado pelo
# irmão anterior ao texto "Minhas contas", que é estável na estrutura da tela.
${BANNER_INDICACAO}                 xpath=//android.widget.TextView[@text="Minhas contas"]/preceding-sibling::*[1]
# Resource-id padrão do Android para o preview de texto na folha de compartilhamento
${TXT_MENSAGEM_COMPARTILHAMENTO}    id=android:id/content_preview_text
${BTN_COMPARTILHAR_MESSAGES}        xpath=//*[@text="Messages"]
# O app de Mensagens pode abrir em telas diferentes dependendo do histórico de
# conversas ("Select conversation" + botão "New message", ou direto em "Select
# recipients") — por isso confirmamos pelo pacote do app, não por texto de tela.
${TELA_APP_MENSAGENS}               xpath=//*[@package="com.google.android.apps.messaging"]

${BTN_GERAR_2VIA_HOME}       accessibility_id=Gerar 2ª via da fatura
${TITULO_POPUP}              accessibility_id=2ª Via da Conta Lumen
# Ano/Mês mudam de rótulo ("Ano" -> "2026") e de estado clicável quando
# habilitados, por isso localizamos pela posição estável do container
# (primeiro filho), não pelo texto ou pelo atributo clickable.
${CAMPO_ANO}                 xpath=//android.widget.TextView[@text="Escolha o mês e ano de referência:"]/following-sibling::*[1]/*[1]
${CAMPO_MES}                 xpath=//android.widget.TextView[@text="Escolha o mês e ano de referência:"]/following-sibling::*[2]/*[1]
${BTN_GERAR_POPUP}           accessibility_id=Gerar 2ª via da fatura

${TAB_PAGAMENTO}             accessibility_id=Pagamento
${TAB_CONSUMO}               accessibility_id=Consumo

# Aba Pagamento: campos são TextViews irmãos, em ordem, logo após o título
${TXT_TITULO_PAGAMENTO}       xpath=//*[@text="Pagamento da conta"]
${TXT_MES_ANO_PAGAMENTO}      xpath=//*[@text="Pagamento da conta"]/following-sibling::android.widget.TextView[1]
${TXT_STATUS_PAGAMENTO}       xpath=//*[@text="Pagamento da conta"]/following-sibling::android.widget.TextView[2]
${TXT_VALOR_PAGAMENTO}        xpath=//*[@text="Pagamento da conta"]/following-sibling::android.widget.TextView[3]
${TXT_VENCIMENTO}             xpath=//*[@text="Pagamento da conta"]/following-sibling::android.widget.TextView[4]
${TXT_ECONOMIA_PAGAMENTO}     xpath=//*[@text="Pagamento da conta"]/following-sibling::android.widget.TextView[5]

# Aba Consumo: valor sempre é o próximo irmão do rótulo correspondente
${TXT_TITULO_CONSUMO}         xpath=//*[@text="Descrição do consumo"]
${TXT_TOTAL_PAGAR_LUMEN}     xpath=//*[@text="Total a pagar com a Lumen"]/following-sibling::*[1]
${TXT_SEM_LUMEN}             xpath=//*[@text="Sem a Lumen você pagaria"]/following-sibling::*[1]
${TXT_ECONOMIA_CONSUMO}       xpath=//*[@text="Sua economia do mês"]/following-sibling::*[1]
${BTN_BAIXAR_CONTA}           xpath=//android.widget.Button[.//*[@text="Baixar conta completa"]]
# Descrição dos valores pode variar por cliente (nem sempre tem as mesmas linhas);
# validamos apenas que a seção existe com pelo menos um valor em R$.
${TITULO_VALOR_LUMEN}        xpath=(//*[@text="Valor da Lumen"])[1]

${TAB_CONTAS}                accessibility_id=Contas
# Mostra "Sua conta não está unificada." OU "Sua conta está unificada."
# (apenas um dos dois aparece por vez), por isso localizamos por texto parcial.
${TXT_BANNER_UNIFICACAO}      xpath=//*[contains(@text, "unificada")]

# Card "Últimas contas em aberto": campos são TextViews irmãos, em ordem, após
# o título. NOTA: o mecanismo de XPath do Appium/UiAutomator2 avalia o eixo
# preceding-sibling em ordem DIRETA do documento (não invertida, como no
# XPath padrão) — por isso ancoramos com following-sibling a partir de um
# título anterior, em vez de contar "de trás pra frente" a partir do botão.
${BTN_PAGAR_CONTA}                accessibility_id=Pagar conta
${TXT_MES_ANO_CONTA_ABERTA}        xpath=//*[@text="Últimas contas em aberto"]/following-sibling::android.widget.TextView[2]
${TXT_STATUS_CONTA_ABERTA}         xpath=//*[@text="Últimas contas em aberto"]/following-sibling::android.widget.TextView[3]
${TXT_VALOR_CONTA_ABERTA}          xpath=//*[@text="Últimas contas em aberto"]/following-sibling::android.widget.TextView[4]
${TXT_VENCIMENTO_CONTA_ABERTA}     xpath=//*[@text="Últimas contas em aberto"]/following-sibling::android.widget.TextView[5]

# Opções de pagamento (só aparecem para conta em aberto). "Pix copia e cola" e
# "Código de barras" copiam pro clipboard (sem mudança visual); "Pix QR code"
# abre um modal.
${OPCAO_PIX_COPIA_COLA}       xpath=//*[starts-with(@content-desc, "Pix copia e cola")]
${OPCAO_CODIGO_BARRAS}        xpath=//*[starts-with(@content-desc, "Código de barras")]
${OPCAO_PIX_QRCODE}           accessibility_id=Pix QR code
${MODAL_QRCODE_TITULO}        accessibility_id=Realize o pagamento
${BTN_FECHAR_MODAL_QRCODE}    xpath=//*[@text="Realize o pagamento"]/following-sibling::*[1]

# "Encaminhar" abre a folha de compartilhamento nativa com um PDF (mesmo
# padrão do banner de indicação, mas compartilhando arquivo em vez de texto).
${BTN_ENCAMINHAR_CONTA}          xpath=//*[contains(@content-desc, "Encaminhar")]
${TXT_ARQUIVO_COMPARTILHADO}     id=com.android.intentresolver:id/content_preview_filename

${BTN_VER_HISTORICO}          xpath=//*[starts-with(@content-desc, "Ver histórico completo de contas")]
${TXT_TITULO_HISTORICO}       xpath=//*[@text="Histórico completo de contas"]

# Aba Indicação (menu inferior) — diferente do banner de indicação da home,
# mas usa o mesmo compartilhamento por trás do botão "Compartilhar".
${TAB_INDICACAO}                accessibility_id=Indicação
${BTN_INDICAR_AMIGO}             xpath=//*[contains(@content-desc, "Indicar amigo")]
${BTN_COMPARTILHAR_INDICACAO}    xpath=//*[contains(@content-desc, "Compartilhar")]
${BTN_COMO_FUNCIONA_INDICACAO}   xpath=//*[contains(@content-desc, "Como funciona o Rede Lumen+?")]
${BTN_ALTERAR_CHAVE_PIX}         xpath=//*[contains(@content-desc, "Alterar chave pix")]

# Formulário "Indique um amigo" (bottom sheet): campos são irmãos do rótulo
# correspondente, filtrados por classe pra não pegar o "*" nem o wrapper.
${CAMPO_NOME_INDICACAO}       xpath=//*[@text="Nome da indicação:"]/following-sibling::android.widget.EditText[1]
${CAMPO_TELEFONE_INDICACAO}   xpath=//*[@text="Telefone da indicação:"]/following-sibling::android.widget.EditText[1]
${BTN_INDICAR_SUBMIT}         accessibility_id=Indicar

${TXT_TITULO_FAQ_INDICACAO}    xpath=//*[@text="Dúvidas sobre o indique e ganhe"]
${TXT_TITULO_CHAVE_PIX}        xpath=//*[@text="Cadastro chave Pix"]
# Erro de validação (telefone com menos de 10 dígitos) aparece como o 2º
# TextView irmão após o rótulo "Telefone da indicação:" (o 1º é o "*").
${TXT_ERRO_TELEFONE_INDICACAO}    xpath=//*[@text="Telefone da indicação:"]/following-sibling::android.widget.TextView[2]

# Ícone de perfil no canto superior esquerdo da home (sem texto/id acessível;
# localizado pela posição — primeiro filho clicável do cabeçalho da home).
${BTN_PERFIL_HOME}              xpath=(//android.view.ViewGroup[@clickable="true"])[1]
${OPCAO_RENOMEAR_INSTALACAO}    xpath=//*[starts-with(@content-desc, "Renomear instalação")]
${TXT_NUMERO_INSTALACAO}        xpath=//*[starts-with(@text, "Instalação ")]


*** Keywords ***
OBTER CAMINHO DO ADB
    ${adb_path}=    Evaluate
    ...    os.path.join(os.environ.get("ANDROID_HOME", os.path.expanduser("~/AppData/Local/Android/Sdk")), "platform-tools", "adb.exe")
    ...    modules=os
    RETURN    ${adb_path}

ABRIR APLICATIVO LUMEN
    # Configuração do dispositivo/app via .env, com defaults para o emulador local padrão.
    ${appium_server}=       Set Variable    %{APPIUM_SERVER_URL=http://127.0.0.1:4723}
    ${device_name}=         Set Variable    %{ANDROID_DEVICE_NAME=emulator-5554}
    ${platform_version}=    Set Variable    %{ANDROID_PLATFORM_VERSION=14}
    ${app_package}=         Set Variable    %{APP_MOBILE_PACKAGE=com.lumenfrontendportal}
    ${app_activity}=        Set Variable    %{APP_MOBILE_ACTIVITY=com.lumenfrontendportal.MainActivity}
    ${adb_path}=    OBTER CAMINHO DO ADB

    &{capabilities}=    Create Dictionary
    ...    platformName=Android
    ...    automationName=UiAutomator2
    ...    deviceName=${device_name}
    ...    platformVersion=${platform_version}
    ...    appPackage=${app_package}
    ...    appActivity=${app_activity}
    ...    noReset=${True}
    ...    newCommandTimeout=120

    # Garante que todo teste comece do zero (tela de boas-vindas), independente
    # de em que tela um teste anterior tenha parado ou falhado.
    Run Process    ${adb_path}    shell    am    force-stop    ${app_package}
    Open Application    ${appium_server}    &{capabilities}

    Set Suite Variable    ${APP_MOBILE_PACKAGE}    ${app_package}

FECHAR APLICATIVO
    Close Application

VOLTAR
    Click Element    xpath=//*[contains(@content-desc, "Voltar")]

ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    ${apareceu}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element    ${PERMISSAO_NOTIFICACAO_ALLOW}    timeout=5s
    Run Keyword If    ${apareceu}    Click Element    ${PERMISSAO_NOTIFICACAO_ALLOW}

IR PARA TELA DE LOGIN
    Wait Until Page Contains Element    ${BTN_ENTRAR_BOASVINDAS}    timeout=10s
    Click Element    ${BTN_ENTRAR_BOASVINDAS}

FAZER LOGIN
    [Arguments]    ${email}    ${senha}
    Wait Until Page Contains Element    ${CAMPO_EMAIL}    timeout=10s
    Input Text    ${CAMPO_EMAIL}    ${email}
    Input Text    ${CAMPO_SENHA}    ${senha}
    Click Element    ${BTN_ENTRAR_LOGIN}

VALIDAR MENSAGEM DE ERRO DE LOGIN
    [Arguments]    ${mensagem_esperada}
    Wait Until Page Contains Element    ${TXT_ERRO_LOGIN}    timeout=10s
    ${mensagem}=    Get Text    ${TXT_ERRO_LOGIN}
    Should Be Equal As Strings    ${mensagem}    ${mensagem_esperada}
    # confirma que o login realmente não foi concluído (segue na tela de login)
    Page Should Contain Element    ${BTN_ENTRAR_LOGIN}

DESATIVAR CONEXAO DE REDE
    ${adb_path}=    OBTER CAMINHO DO ADB
    Run Process    ${adb_path}    shell    svc    wifi    disable
    Run Process    ${adb_path}    shell    svc    data    disable
    Sleep    2s

REATIVAR CONEXAO DE REDE
    # Sempre chamado no teardown dos testes que desativam a rede — mesmo se o
    # teste falhar, o emulador não pode ficar sem internet pros testes seguintes.
    ${adb_path}=    OBTER CAMINHO DO ADB
    Run Process    ${adb_path}    shell    svc    wifi    enable
    Run Process    ${adb_path}    shell    svc    data    enable
    Sleep    2s

CONCLUIR LOGIN E AGUARDAR HOME
    # Após logar, o app pode mostrar 0, 1 ou 2 telas opcionais (salvar dados de
    # acesso, habilitar biometria) dependendo se o usuário já respondeu antes.
    # Ambas usam o mesmo botão "Pular"; vamos clicando nele até a home aparecer.
    FOR    ${tentativa}    IN RANGE    10
        ${home_visivel}=    Run Keyword And Return Status    Page Should Contain Element    ${BTN_INICIO_HOME}
        Exit For Loop If    ${home_visivel}
        ${pular_visivel}=    Run Keyword And Return Status    Page Should Contain Element    ${BTN_PULAR}
        Run Keyword If    ${pular_visivel}    Click Element    ${BTN_PULAR}
        Sleep    1s
    END
    Wait Until Page Contains Element    ${BTN_INICIO_HOME}    timeout=10s

CONFIRMAR HOME CARREGADA
    Wait Until Page Contains Element    ${BTN_INICIO_HOME}    timeout=15s

ABRIR BANNER DE INDICACAO
    Wait Until Page Contains Element    ${BANNER_INDICACAO}    timeout=10s
    Click Element    ${BANNER_INDICACAO}

VALIDAR MENSAGEM PADRAO DE INDICACAO
    Wait Until Page Contains Element    ${TXT_MENSAGEM_COMPARTILHAMENTO}    timeout=10s
    ${mensagem}=    Get Text    ${TXT_MENSAGEM_COMPARTILHAMENTO}
    Should Contain    ${mensagem}    Ei, quero te indicar algo que tem me ajudado muito
    Should Contain    ${mensagem}    economizando todo mês na conta de luz com a Lumen Energia
    Should Contain    ${mensagem}    É super simples, tudo online, não precisa instalar nada e nenhum investimento
    Should Contain    ${mensagem}    Descubra o quanto você pode economizar
    # PIN do cliente é dinâmico (varia por conta), então validamos o padrão da URL em vez de um valor fixo
    Should Match Regexp    ${mensagem}    https://cloud\\.economia\\.lumenenergia\\.com\\.br/lumenmaiscontratacaocogni2/\\?pin=\\S+

SELECIONAR COMPARTILHAMENTO VIA MENSAGENS
    Wait Until Page Contains Element    ${BTN_COMPARTILHAR_MESSAGES}    timeout=10s
    Click Element    ${BTN_COMPARTILHAR_MESSAGES}

CONFIRMAR DIRECIONAMENTO PARA ENVIO
    Wait Until Page Contains Element    ${TELA_APP_MENSAGENS}    timeout=10s

CANCELAR COMPARTILHAMENTO SEM ENVIAR
    # Traz o app da Lumen de volta ao primeiro plano diretamente, sem depender
    # da pilha de back do app de destino do compartilhamento (imprevisível).
    Activate Application    ${APP_MOBILE_PACKAGE}
    CONFIRMAR HOME CARREGADA

ABRIR POPUP SEGUNDA VIA
    Wait Until Page Contains Element    ${BTN_GERAR_2VIA_HOME}    timeout=10s
    Click Element    ${BTN_GERAR_2VIA_HOME}
    Wait Until Page Contains Element    ${TITULO_POPUP}    timeout=10s

VALIDAR ESTADO INICIAL DO POPUP
    Element Should Be Disabled    ${CAMPO_MES}
    Element Should Be Disabled    ${BTN_GERAR_POPUP}

SELECIONAR ANO
    [Arguments]    ${ano}
    Click Element    ${CAMPO_ANO}
    Wait Until Page Contains Element    accessibility_id=${ano}    timeout=5s
    Click Element    accessibility_id=${ano}

SELECIONAR MES
    [Arguments]    ${mes}
    Click Element    ${CAMPO_MES}
    Wait Until Page Contains Element    accessibility_id=${mes}    timeout=5s
    Click Element    accessibility_id=${mes}

VALIDAR MES HABILITADO E BOTAO AINDA DESABILITADO
    Wait Until Page Contains Element    ${CAMPO_MES}    timeout=5s
    Element Should Be Enabled    ${CAMPO_MES}
    Element Should Be Disabled    ${BTN_GERAR_POPUP}

VALIDAR BOTAO GERAR HABILITADO
    Wait Until Page Contains Element    ${BTN_GERAR_POPUP}    timeout=5s
    Element Should Be Enabled    ${BTN_GERAR_POPUP}

CLICAR EM GERAR SEGUNDA VIA
    Wait Until Page Contains Element    ${BTN_GERAR_POPUP}    timeout=5s
    Click Element    ${BTN_GERAR_POPUP}
    Wait Until Page Contains Element    ${TXT_TITULO_PAGAMENTO}    timeout=15s

VALIDAR ABA PAGAMENTO
    [Arguments]    ${mes}    ${ano}
    Wait Until Page Contains Element    ${TXT_TITULO_PAGAMENTO}    timeout=10s
    ${mes_ano}=    Get Text    ${TXT_MES_ANO_PAGAMENTO}
    Should Be Equal As Strings    ${mes_ano}    ${mes}/${ano}
    ${valor}=    Get Text    ${TXT_VALOR_PAGAMENTO}
    Should Match Regexp    ${valor}    ^R\\$\\s\\d{1,3}(\\.\\d{3})*,\\d{2}$
    ${vencimento}=    Get Text    ${TXT_VENCIMENTO}
    Should Match Regexp    ${vencimento}    ^Vencimento: \\d{2}/\\d{2}/\\d{4}$
    ${economia}=    Get Text    ${TXT_ECONOMIA_PAGAMENTO}
    Should Match Regexp    ${economia}    ^Sua economia este mês é R\\$\\s\\d{1,3}(\\.\\d{3})*,\\d{2}$
    # status do pagamento existe e não está vazio (ex: Pago, Pendente, Vencido)
    ${status}=    Get Text    ${TXT_STATUS_PAGAMENTO}
    Should Not Be Empty    ${status}
    ${dados}=    Create Dictionary
    ...    mes_ano=${mes_ano}    valor=${valor}    status=${status}
    ...    vencimento=${vencimento}    economia=${economia}
    RETURN    ${dados}

IR PARA ABA CONSUMO
    Click Element    ${TAB_CONSUMO}
    Wait Until Page Contains Element    ${TXT_TITULO_CONSUMO}    timeout=10s

VALIDAR ABA CONSUMO
    Wait Until Page Contains Element    ${TXT_TITULO_CONSUMO}    timeout=10s
    Wait Until Page Contains Element    ${TXT_TOTAL_PAGAR_LUMEN}    timeout=10s
    ${total_lumen}=    Get Text    ${TXT_TOTAL_PAGAR_LUMEN}
    Should Match Regexp    ${total_lumen}    ^R\\$\\s\\d{1,3}(\\.\\d{3})*,\\d{2}$
    ${sem_lumen}=    Get Text    ${TXT_SEM_LUMEN}
    Should Match Regexp    ${sem_lumen}    ^R\\$\\s\\d{1,3}(\\.\\d{3})*,\\d{2}$
    ${economia}=    Get Text    ${TXT_ECONOMIA_CONSUMO}
    Should Match Regexp    ${economia}    ^R\\$\\s\\d{1,3}(\\.\\d{3})*,\\d{2}$
    Page Should Contain Element    ${BTN_BAIXAR_CONTA}
    Element Should Be Enabled    ${BTN_BAIXAR_CONTA}
    Page Should Contain Element    ${TITULO_VALOR_LUMEN}
    ${dados}=    Create Dictionary
    ...    total_lumen=${total_lumen}    sem_lumen=${sem_lumen}    economia=${economia}
    RETURN    ${dados}

IR PARA ABA CONTAS
    Wait Until Page Contains Element    ${TAB_CONTAS}    timeout=10s
    Click Element    ${TAB_CONTAS}
    Wait Until Page Contains Element    ${TXT_BANNER_UNIFICACAO}    timeout=10s

OBTER TEXTO DO BANNER DE UNIFICACAO
    ${texto}=    Get Text    ${TXT_BANNER_UNIFICACAO}
    RETURN    ${texto}

OBTER DADOS DA CONTA EM ABERTO
    Wait Until Page Contains Element    ${BTN_PAGAR_CONTA}    timeout=10s
    ${mes_ano}=    Get Text    ${TXT_MES_ANO_CONTA_ABERTA}
    ${status}=    Get Text    ${TXT_STATUS_CONTA_ABERTA}
    ${valor}=    Get Text    ${TXT_VALOR_CONTA_ABERTA}
    ${vencimento}=    Get Text    ${TXT_VENCIMENTO_CONTA_ABERTA}
    Should Be Equal As Strings    ${status}    Em aberto
    Should Match Regexp    ${valor}    ^R\\$\\s\\d{1,3}(\\.\\d{3})*,\\d{2}$
    Should Match Regexp    ${vencimento}    ^Vencimento: \\d{2}/\\d{2}/\\d{4}$
    ${dados}=    Create Dictionary
    ...    mes_ano=${mes_ano}    status=${status}    valor=${valor}    vencimento=${vencimento}
    RETURN    ${dados}

CLICAR EM PAGAR CONTA
    Wait Until Page Contains Element    ${BTN_PAGAR_CONTA}    timeout=10s
    Click Element    ${BTN_PAGAR_CONTA}
    Wait Until Page Contains Element    ${TXT_TITULO_PAGAMENTO}    timeout=10s

VALIDAR OPCOES DE PAGAMENTO DISPONIVEIS
    Wait Until Page Contains Element    ${OPCAO_PIX_COPIA_COLA}    timeout=10s
    Element Should Be Enabled    ${OPCAO_PIX_COPIA_COLA}
    Page Should Contain Element    ${OPCAO_CODIGO_BARRAS}
    Element Should Be Enabled    ${OPCAO_CODIGO_BARRAS}
    Page Should Contain Element    ${OPCAO_PIX_QRCODE}
    Element Should Be Enabled    ${OPCAO_PIX_QRCODE}

ABRIR PIX QR CODE
    Click Element    ${OPCAO_PIX_QRCODE}
    Wait Until Page Contains Element    ${MODAL_QRCODE_TITULO}    timeout=10s

FECHAR MODAL QR CODE
    Click Element    ${BTN_FECHAR_MODAL_QRCODE}
    Wait Until Page Does Not Contain Element    ${MODAL_QRCODE_TITULO}    timeout=10s

CLICAR EM ENCAMINHAR CONTA
    Wait Until Page Contains Element    ${BTN_ENCAMINHAR_CONTA}    timeout=10s
    Click Element    ${BTN_ENCAMINHAR_CONTA}

VALIDAR ARQUIVO DE CONTA COMPARTILHADO
    [Arguments]    ${mes_ano}
    Wait Until Page Contains Element    ${TXT_ARQUIVO_COMPARTILHADO}    timeout=10s
    ${nome_arquivo}=    Get Text    ${TXT_ARQUIVO_COMPARTILHADO}
    ${mes_ano_com_hifen}=    Evaluate    """${mes_ano}""".replace("/", "-")
    Should Be Equal As Strings    ${nome_arquivo}    Conta Lumen-${mes_ano_com_hifen}.pdf

IR PARA HISTORICO COMPLETO DE CONTAS
    Wait Until Page Contains Element    ${BTN_VER_HISTORICO}    timeout=10s
    Click Element    ${BTN_VER_HISTORICO}
    Wait Until Page Contains Element    ${TXT_TITULO_HISTORICO}    timeout=10s

VALIDAR LISTA DE HISTORICO DE CONTAS
    # Cada conta do histórico (paga ou em aberto) tem um botão "Encaminhar";
    # validamos que a lista tem mais de uma conta, sem fixar a quantidade
    # exata (varia por cliente/tempo de casa).
    ${qtd_contas}=    Get Matching Xpath Count    //*[contains(@content-desc, "Encaminhar")]
    Should Be True    ${qtd_contas} >= 2

IR PARA ABA INDICACAO
    Wait Until Page Contains Element    ${TAB_INDICACAO}    timeout=10s
    Click Element    ${TAB_INDICACAO}
    Wait Until Page Contains Element    ${BTN_INDICAR_AMIGO}    timeout=10s

ABRIR FORMULARIO INDICAR AMIGO
    Click Element    ${BTN_INDICAR_AMIGO}
    Wait Until Page Contains Element    ${BTN_INDICAR_SUBMIT}    timeout=10s

VALIDAR BOTAO INDICAR DESABILITADO
    Element Should Be Disabled    ${BTN_INDICAR_SUBMIT}

PREENCHER FORMULARIO INDICAR AMIGO
    [Arguments]    ${nome}    ${telefone}
    Input Text    ${CAMPO_NOME_INDICACAO}    ${nome}
    Input Text    ${CAMPO_TELEFONE_INDICACAO}    ${telefone}

VALIDAR TELEFONE COM MASCARA APLICADA
    ${valor}=    Get Text    ${CAMPO_TELEFONE_INDICACAO}
    Should Match Regexp    ${valor}    ^\\(\\d{2}\\) \\d{4,5}-\\d{4}$

VALIDAR BOTAO INDICAR HABILITADO
    Wait Until Page Contains Element    ${BTN_INDICAR_SUBMIT}    timeout=5s
    Element Should Be Enabled    ${BTN_INDICAR_SUBMIT}

VALIDAR ERRO DE TELEFONE INVALIDO
    Wait Until Page Contains Element    ${TXT_ERRO_TELEFONE_INDICACAO}    timeout=10s
    ${mensagem}=    Get Text    ${TXT_ERRO_TELEFONE_INDICACAO}
    Should Be Equal As Strings    ${mensagem}    Telefone deve ter pelo menos 10 dígitos
    Element Should Be Disabled    ${BTN_INDICAR_SUBMIT}

FECHAR FORMULARIO SEM ENVIAR
    # Não clicamos em "Indicar": isso enviaria um convite real. Fechamos com o
    # botão de voltar do sistema.
    Press Keycode    4
    Wait Until Page Does Not Contain Element    ${BTN_INDICAR_SUBMIT}    timeout=10s

CLICAR EM COMPARTILHAR INDICACAO
    Wait Until Page Contains Element    ${BTN_COMPARTILHAR_INDICACAO}    timeout=10s
    Click Element    ${BTN_COMPARTILHAR_INDICACAO}

ABRIR COMO FUNCIONA INDICACAO
    Wait Until Page Contains Element    ${BTN_COMO_FUNCIONA_INDICACAO}    timeout=10s
    Click Element    ${BTN_COMO_FUNCIONA_INDICACAO}
    Wait Until Page Contains Element    ${TXT_TITULO_FAQ_INDICACAO}    timeout=10s

IR PARA ALTERAR CHAVE PIX
    Wait Until Page Contains Element    ${BTN_ALTERAR_CHAVE_PIX}    timeout=10s
    Click Element    ${BTN_ALTERAR_CHAVE_PIX}
    Wait Until Page Contains Element    ${TXT_TITULO_CHAVE_PIX}    timeout=10s

ABRIR MENU DE PERFIL
    Wait Until Page Contains Element    ${BTN_PERFIL_HOME}    timeout=10s
    Click Element    ${BTN_PERFIL_HOME}
    Wait Until Page Contains Element    ${OPCAO_RENOMEAR_INSTALACAO}    timeout=10s

IR PARA RENOMEAR INSTALACAO
    Click Element    ${OPCAO_RENOMEAR_INSTALACAO}
    Wait Until Page Contains Element    ${TXT_NUMERO_INSTALACAO}    timeout=10s

OBTER NUMERO DA INSTALACAO
    ${texto}=    Get Text    ${TXT_NUMERO_INSTALACAO}
    ${numero}=    Evaluate    """${texto}""".replace("Instalação ", "").strip()
    RETURN    ${numero}
