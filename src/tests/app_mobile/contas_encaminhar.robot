*** Settings ***
Documentation    Valida que "Encaminhar" na conta em aberto (aba Contas) abre o
...              compartilhamento nativo com o PDF correto da conta do mês
...              vigente. Não conclui o envio.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
ENCAMINHAR CONTA COMPARTILHA O PDF CORRETO
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    IR PARA ABA CONTAS
    ${dados_conta}=    OBTER DADOS DA CONTA EM ABERTO
    CLICAR EM ENCAMINHAR CONTA
    VALIDAR ARQUIVO DE CONTA COMPARTILHADO    ${dados_conta}[mes_ano]
    CANCELAR COMPARTILHAMENTO SEM ENVIAR
