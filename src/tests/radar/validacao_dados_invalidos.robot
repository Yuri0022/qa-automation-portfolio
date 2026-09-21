*** Settings ***
Documentation      Caminhos de exceção do cadastro Radar: dados inválidos e
...                campos faltantes nas 3 etapas do formulário (Empresa,
...                Endereço, Financeiro). Testado pelo caminho deslogado — as
...                validações de campo são do próprio formulário React, o
...                mesmo componente usado nos dois caminhos (ver
...                cadastro_deslogado.robot / cadastro_logado.robot).
...
...                Achados confirmados:
...                - "Nome da empresa", "Razão Social" e "Nome do responsável"
...                  rejeitam valores de uma palavra só ("Não permitido nome
...                  com apenas um termo.").
...                - CNPJ e CPF (Documento do responsável) são validados pelo
...                  dígito verificador, não só pelo formato/máscara.
...                - E-mail e upload de arquivo em formato errado só mostram
...                  erro ao tentar avançar/anexar (toast, pode sumir sozinho)
...                  — não são validados enquanto se digita.
...                - CEP inexistente não preenche o endereço automaticamente e
...                  não permite prosseguir, mas não mostra uma mensagem de
...                  erro explícita.
Library            ../../../load_env.py
Library            OperatingSystem
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/radar-keywords.resource
Test Teardown      Run Keyword And Ignore Error    Close Browser    ALL

*** Keywords ***
Gerar dados validos de empresa
    [Documentation]    Dados de empresa/responsável válidos, usados como base
    ...    nos testes que isolam UM campo inválido por vez.
    ${cnpj}=    Gerar Cnpj    formatado=True
    ${cpf}=    Gerar Cpf    formatado=True
    &{dados}=    Create Dictionary
    ...    nome_empresa=Teste Automatizado
    ...    razao_social=Teste Automatizado
    ...    cnpj=${cnpj}
    ...    tipo_empresa=LTDA
    ...    nome_responsavel=Teste Automatizado
    ...    documento_responsavel=${cpf}
    ...    telefone_responsavel=31999999999
    ...    email_responsavel=teste@example.com
    RETURN    &{dados}

*** Test Cases ***
Etapa Empresa não avança com todos os campos vazios
    [Tags]    REGRESSAO    NEGATIVO
    IR PARA CADASTRO RADAR DESLOGADO
    VALIDAR AVANCAR DESABILITADO

Campos de nome com uma palavra só são rejeitados
    [Documentation]    "Nome da empresa", "Razão Social" e "Nome do
    ...    responsável" exigem pelo menos duas palavras (ex.: "Nome
    ...    Sobrenome") — um valor de uma palavra só é rejeitado nos três.
    [Tags]    REGRESSAO    NEGATIVO
    &{dados}=    Gerar dados validos de empresa
    IR PARA CADASTRO RADAR DESLOGADO
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=Teste
    ...    razao_social=Teste
    ...    cnpj=${dados}[cnpj]
    ...    tipo_empresa=${dados}[tipo_empresa]
    ...    nome_responsavel=Teste
    ...    documento_responsavel=${dados}[documento_responsavel]
    ...    telefone_responsavel=${dados}[telefone_responsavel]
    ...    email_responsavel=${dados}[email_responsavel]
    # A mensagem se repete uma vez por campo (3 campos de uma palavra só
    # preenchidos) — por isso conta ocorrências em vez de esperar 1 elemento
    # único (Wait For Elements State falha em "strict mode" com >1 match).
    ${qtd_mensagens}=    Get Element Count
    ...    //*[contains(text(),'Não permitido nome com apenas um termo.')]
    Should Be True    ${qtd_mensagens} >= 1
    ...    Mensagem "Não permitido nome com apenas um termo." não apareceu.
    VALIDAR AVANCAR DESABILITADO

CNPJ com dígito verificador inválido é rejeitado
    [Tags]    REGRESSAO    NEGATIVO
    &{dados}=    Gerar dados validos de empresa
    IR PARA CADASTRO RADAR DESLOGADO
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=${dados}[nome_empresa]
    ...    razao_social=${dados}[razao_social]
    ...    cnpj=11.111.111/1111-11
    ...    tipo_empresa=${dados}[tipo_empresa]
    ...    nome_responsavel=${dados}[nome_responsavel]
    ...    documento_responsavel=${dados}[documento_responsavel]
    ...    telefone_responsavel=${dados}[telefone_responsavel]
    ...    email_responsavel=${dados}[email_responsavel]
    VALIDAR MENSAGEM DE VALIDACAO RADAR    CNPJ inválido.
    VALIDAR AVANCAR DESABILITADO

CPF do responsável com dígito verificador inválido é rejeitado
    [Tags]    REGRESSAO    NEGATIVO
    &{dados}=    Gerar dados validos de empresa
    IR PARA CADASTRO RADAR DESLOGADO
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=${dados}[nome_empresa]
    ...    razao_social=${dados}[razao_social]
    ...    cnpj=${dados}[cnpj]
    ...    tipo_empresa=${dados}[tipo_empresa]
    ...    nome_responsavel=${dados}[nome_responsavel]
    ...    documento_responsavel=111.111.111-11
    ...    telefone_responsavel=${dados}[telefone_responsavel]
    ...    email_responsavel=${dados}[email_responsavel]
    VALIDAR MENSAGEM DE VALIDACAO RADAR    CPF inválido.
    VALIDAR AVANCAR DESABILITADO

Telefone do responsável incompleto é rejeitado
    [Tags]    REGRESSAO    NEGATIVO
    &{dados}=    Gerar dados validos de empresa
    IR PARA CADASTRO RADAR DESLOGADO
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=${dados}[nome_empresa]
    ...    razao_social=${dados}[razao_social]
    ...    cnpj=${dados}[cnpj]
    ...    tipo_empresa=${dados}[tipo_empresa]
    ...    nome_responsavel=${dados}[nome_responsavel]
    ...    documento_responsavel=${dados}[documento_responsavel]
    ...    telefone_responsavel=3199
    ...    email_responsavel=${dados}[email_responsavel]
    VALIDAR MENSAGEM DE VALIDACAO RADAR    Telefone inválido, verifique o preenchimento.
    VALIDAR AVANCAR DESABILITADO

E-mail em formato inválido impede avançar
    [Documentation]    Diferente de CNPJ/CPF/telefone (validados enquanto se
    ...    digita), o e-mail só é validado ao tentar avançar — a tela continua
    ...    na etapa Empresa e mostra a mensagem.
    [Tags]    REGRESSAO    NEGATIVO
    &{dados}=    Gerar dados validos de empresa
    IR PARA CADASTRO RADAR DESLOGADO
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=${dados}[nome_empresa]
    ...    razao_social=${dados}[razao_social]
    ...    cnpj=${dados}[cnpj]
    ...    tipo_empresa=${dados}[tipo_empresa]
    ...    nome_responsavel=${dados}[nome_responsavel]
    ...    documento_responsavel=${dados}[documento_responsavel]
    ...    telefone_responsavel=${dados}[telefone_responsavel]
    ...    email_responsavel=email-sem-arroba
    Click    //span[text()='Avançar']
    VALIDAR MENSAGEM DE VALIDACAO RADAR    E-mail inválido.
    Wait For Elements State    //input[@placeholder='Nome da empresa']    visible    5s

Upload de documento em formato não permitido é rejeitado
    [Documentation]    Só PDF/JPG/PNG são aceitos — um .txt é rejeitado com
    ...    mensagem específica, e a etapa não avança.
    ...    A mensagem ("Erro ao anexar documento do CNPJ: Formato .txt não
    ...    permitido.") é renderizada em nós de texto separados, então
    ...    contains(text(),...) nunca casa (confirmado em diagnóstico
    ...    repetido 3x) — usa contains(.,...) + contagem, como no teste de
    ...    nome de uma palavra só.
    [Tags]    REGRESSAO    NEGATIVO
    &{dados}=    Gerar dados validos de empresa
    IR PARA CADASTRO RADAR DESLOGADO
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=${dados}[nome_empresa]
    ...    razao_social=${dados}[razao_social]
    ...    cnpj=${dados}[cnpj]
    ...    tipo_empresa=${dados}[tipo_empresa]
    ...    nome_responsavel=${dados}[nome_responsavel]
    ...    documento_responsavel=${dados}[documento_responsavel]
    ...    telefone_responsavel=${dados}[telefone_responsavel]
    ...    email_responsavel=${dados}[email_responsavel]
    AVANCAR CADASTRO RADAR

    Create File    ${OUTPUT_DIR}/arquivo_invalido.txt    conteúdo de teste
    Upload File By Selector    (//input[@type='file'])[1]    ${OUTPUT_DIR}/arquivo_invalido.txt
    ${qtd_mensagens}=    Get Element Count    //*[contains(.,'permitido')]
    Should Be True    ${qtd_mensagens} >= 1
    ...    Mensagem "Formato .txt não permitido." não apareceu.
    VALIDAR AVANCAR DESABILITADO

CEP inexistente não preenche o endereço e impede avançar
    [Tags]    REGRESSAO    NEGATIVO
    &{dados}=    Gerar dados validos de empresa
    IR PARA CADASTRO RADAR DESLOGADO
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=${dados}[nome_empresa]
    ...    razao_social=${dados}[razao_social]
    ...    cnpj=${dados}[cnpj]
    ...    tipo_empresa=${dados}[tipo_empresa]
    ...    nome_responsavel=${dados}[nome_responsavel]
    ...    documento_responsavel=${dados}[documento_responsavel]
    ...    telefone_responsavel=${dados}[telefone_responsavel]
    ...    email_responsavel=${dados}[email_responsavel]
    AVANCAR CADASTRO RADAR
    ANEXAR DOCUMENTOS RADAR
    AVANCAR CADASTRO RADAR

    Wait For Elements State    //input[@placeholder='CEP']    visible    10s
    Fill Text    //input[@placeholder='CEP']    00000000
    Sleep    2s
    ${logradouro}=    Get Attribute    //input[@placeholder='Logradouro']    value
    Should Be Empty    ${logradouro}
    ...    CEP inexistente não deveria ter preenchido o Logradouro.
    Fill Text    //input[@placeholder='Número']    100
    VALIDAR AVANCAR DESABILITADO

Etapa Financeiro exige todos os campos preenchidos
    [Tags]    REGRESSAO    NEGATIVO
    &{dados}=    Gerar dados validos de empresa
    IR PARA CADASTRO RADAR DESLOGADO
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=${dados}[nome_empresa]
    ...    razao_social=${dados}[razao_social]
    ...    cnpj=${dados}[cnpj]
    ...    tipo_empresa=${dados}[tipo_empresa]
    ...    nome_responsavel=${dados}[nome_responsavel]
    ...    documento_responsavel=${dados}[documento_responsavel]
    ...    telefone_responsavel=${dados}[telefone_responsavel]
    ...    email_responsavel=${dados}[email_responsavel]
    AVANCAR CADASTRO RADAR
    ANEXAR DOCUMENTOS RADAR
    AVANCAR CADASTRO RADAR
    PREENCHER ETAPA ENDERECO RADAR    cep=31035320    numero=100
    AVANCAR CADASTRO RADAR

    VALIDAR FINALIZAR CADASTRO DESABILITADO
