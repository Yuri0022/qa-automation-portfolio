*** Settings ***
Documentation    Valida o fluxo de pagamento da conta em aberto (aba Contas):
...              opções de pagamento disponíveis (Pix copia e cola, Código de
...              barras, Pix QR code) e o modal do QR code.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
PAGAR CONTA MOSTRA OPCOES DE PAGAMENTO E QR CODE FUNCIONA
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    IR PARA ABA CONTAS
    OBTER DADOS DA CONTA EM ABERTO
    CLICAR EM PAGAR CONTA
    VALIDAR OPCOES DE PAGAMENTO DISPONIVEIS
    ABRIR PIX QR CODE
    FECHAR MODAL QR CODE
