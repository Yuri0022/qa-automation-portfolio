*** Settings ***
Documentation      Valida o fluxo de pagamento da conta em aberto (aba Contas):
...                opções de pagamento disponíveis (Pix copia e cola, código de
...                barras, Pix QR code) e o modal do QR code. Equivalente web de
...                src/tests/app_mobile/contas_pagamento.robot.
...
...                Verificado contra uma conta de expansão (PF fora
...                de MG) que tinha uma fatura em aberto de verdade — a conta de
...                MG configurada neste arquivo pode não ter conta em aberto no
...                momento da execução, por isso o teste pula (SKIP) quando não
...                houver, em vez de falhar.
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-titular-keywords.resource
Test Setup         Login comum no portal do titular
Test Teardown      ENCERRAR TESTE PORTAL DO TITULAR

*** Keywords ***
Login comum no portal do titular
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    LOGIN NO PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR}    %{PASSWORD_PORTAL_TITULAR}

*** Test Cases ***
Pagar conta mostra opções de pagamento e QR code funciona
    [Documentation]    Pula com aviso se não houver conta em aberto no momento.
    [Tags]    REGRESSAO
    IR PARA ABA CONTAS
    ${existe}=    CONTA EM ABERTO EXISTE
    IF    not ${existe}
        Skip    Nenhuma conta em aberto no momento para esta conta de teste.
    END
    CLICAR EM PAGAR CONTA
    VALIDAR OPCOES DE PAGAMENTO DISPONIVEIS
    ABRIR PIX QR CODE
    FECHAR MODAL QR CODE
