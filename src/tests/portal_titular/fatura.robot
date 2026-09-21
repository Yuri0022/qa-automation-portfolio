*** Settings ***
Documentation      Valida o popup de 2ª via da fatura (habilitação progressiva dos
...                campos Ano/Mês/Gerar) e a aba Pagamento da tela gerada.
...                Equivalente web de src/tests/app_mobile/fatura.robot.
...
...                A aba "Consumo" não é validada em detalhe aqui — ver nota em
...                IR PARA ABA CONSUMO no resource (spinner que não resolveu em
...                execuções manuais contra homologação).
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-titular-keywords.resource
Test Setup         Login comum no portal do titular
Test Teardown      ENCERRAR TESTE PORTAL DO TITULAR

*** Variables ***
${ANO_TESTE}     2026
${MES_TESTE}     Junho

*** Keywords ***
Login comum no portal do titular
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    LOGIN NO PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR}    %{PASSWORD_PORTAL_TITULAR}

*** Test Cases ***
Popup de segunda via habilita campos na ordem correta
    [Tags]    REGRESSAO
    ABRIR POPUP SEGUNDA VIA
    VALIDAR ESTADO INICIAL DO POPUP SEGUNDA VIA
    SELECIONAR ANO SEGUNDA VIA    ${ANO_TESTE}
    SELECIONAR MES SEGUNDA VIA    ${MES_TESTE}
    VALIDAR BOTAO GERAR HABILITADO

Segunda via mostra aba Pagamento com dados válidos
    [Tags]    REGRESSAO
    ABRIR POPUP SEGUNDA VIA
    SELECIONAR ANO SEGUNDA VIA    ${ANO_TESTE}
    SELECIONAR MES SEGUNDA VIA    ${MES_TESTE}
    CLICAR EM GERAR SEGUNDA VIA
    VALIDAR ABA PAGAMENTO    ${MES_TESTE}    ${ANO_TESTE}
    IR PARA ABA CONSUMO
