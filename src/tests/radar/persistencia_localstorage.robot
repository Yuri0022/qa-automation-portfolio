*** Settings ***
Documentation      Valida que o progresso do cadastro Radar sobrevive a fechar e
...                reabrir a aba — o formulário salva tudo no localStorage
...                (chave "partnerRegisterState": versão, etapa atual e valores
...                de todos os campos). Testado pelo caminho deslogado porque o
...                mecanismo (localStorage por origem) independe de estar
...                logado — o mesmo vale para o caminho logado.
...
...                Confirmado: fechar/reabrir não só mantém os
...                valores já digitados, como também restaura a ETAPA exata em
...                que o usuário parou (ex.: se parou na tela de anexar
...                documentos, volta direto pra lá, não para o início).
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/radar-keywords.resource
Test Teardown      Run Keyword And Ignore Error    Close Browser    ALL

*** Test Cases ***
Dados preenchidos persistem ao fechar e reabrir a aba
    [Tags]    REGRESSAO
    ${cnpj}=    Gerar Cnpj    formatado=True
    ${cpf}=    Gerar Cpf    formatado=True
    ${email}=    FakerLibrary.Email

    IR PARA CADASTRO RADAR DESLOGADO
    PREENCHER ETAPA EMPRESA RADAR
    ...    nome_empresa=Lumen Teste Persistencia LTDA
    ...    razao_social=Lumen Teste Persistencia LTDA
    ...    cnpj=${cnpj}
    ...    tipo_empresa=LTDA
    ...    nome_responsavel=Teste Automatizado
    ...    documento_responsavel=${cpf}
    ...    telefone_responsavel=31999999999
    ...    email_responsavel=${email}
    AVANCAR CADASTRO RADAR

    FECHAR E REABRIR CADASTRO RADAR    https://parceiro-dev.lumenenergia.com.br/register-radar-forms/

    # A etapa (anexar documentos) deve continuar a mesma de antes de fechar —
    # não deveria ter voltado pro início do formulário. "contains(., ...)" em
    # vez de "contains(text(), ...)": o texto do botão vem quebrado em mais de
    # um text node (mesmo padrão já visto em outras telas do projeto), então
    # text() (só o texto direto do elemento) não casa — "." pega o texto de
    # todos os descendentes também.
    Wait For Elements State    //button[contains(.,'Anexar Cart')]    visible    10s

    VOLTAR ETAPA RADAR
    Wait For Elements State    //input[@placeholder='Nome da empresa']    visible    10s

    ${nome_persistido}=    Get Attribute    //input[@placeholder='Nome da empresa']    value
    ${cnpj_persistido}=    Get Attribute    //input[@placeholder='CNPJ']    value
    ${responsavel_persistido}=    Get Attribute    //input[@placeholder='Nome do responsável']    value
    ${documento_persistido}=    Get Attribute    //input[@placeholder='Documento do responsável']    value
    ${telefone_persistido}=    Get Attribute    //input[@placeholder='Telefone do responsável']    value
    ${email_persistido}=    Get Attribute    //input[@placeholder='E-mail do responsável']    value

    # ignore_case nos campos de texto livre: a tela deixa "Nome da empresa" e
    # "Nome do responsável" em maiúsculas (mesmo padrão já visto no Salesforce),
    # independente do que foi digitado.
    Should Be Equal As Strings    ${nome_persistido}    Lumen Teste Persistencia LTDA    ignore_case=True
    Should Be Equal As Strings    ${cnpj_persistido}    ${cnpj}
    Should Be Equal As Strings    ${responsavel_persistido}    Teste Automatizado    ignore_case=True
    Should Be Equal As Strings    ${documento_persistido}    ${cpf}
    # O campo aplica máscara de telefone automaticamente.
    Should Be Equal As Strings    ${telefone_persistido}    (31) 99999-9999
    Should Be Equal As Strings    ${email_persistido}    ${email}    ignore_case=True
