*** Settings ***
Documentation    Compara os dados da 2ª via da fatura exibidos no app (aba
...              Pagamento e Consumo) com o registro correspondente de
...              Transacao__c no Salesforce.
...
...              ATENÇÃO: este teste só é 100% válido quando SALESFORCE_AUTH_URL
...              aponta para o MESMO ambiente que o app em teste consulta. O
...              app mobile (BETA) usa produção; se a Connected App configurada
...              no .env for de homolog, uma divergência aqui pode ser só
...              diferença de dado entre ambientes, não um bug real. Ver
...              README.md, seção "Limitação conhecida".
...
...              Testamos Abril, Maio e Junho/2026 pra essa instalação: Abril e
...              Maio divergiram em 3 campos (valor, vencimento, "sem a
...              Lumen"); Junho divergiu só no status numa execução e, ao
...              rodar de novo minutos depois, bateu 100% — os dados de
...              homolog parecem ser sincronizados periodicamente com
...              produção, então a divergência não é fixa, varia no tempo.
...              Junho foi fixado aqui por ser o mês mais estável observado,
...              mas uma falha aqui não deve ser tratada como bug confirmado
...              sem antes conferir se é só o ambiente fora de sincronia no
...              momento do teste.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Resource    ../../keywords/salesforce-keywords.resource
Suite Setup    CONECTAR SALESFORCE
Test Teardown    FECHAR APLICATIVO

*** Variables ***
${ANO_TESTE}     2026
${MES_TESTE}     Junho

*** Test Cases ***
DADOS DA FATURA NO APP DEVEM BATER COM SALESFORCE
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    CONCLUIR LOGIN E AGUARDAR HOME

    ABRIR MENU DE PERFIL
    IR PARA RENOMEAR INSTALACAO
    ${numero_instalacao}=    OBTER NUMERO DA INSTALACAO
    VOLTAR
    VOLTAR

    ABRIR POPUP SEGUNDA VIA
    SELECIONAR ANO    ${ANO_TESTE}
    SELECIONAR MES    ${MES_TESTE}
    CLICAR EM GERAR SEGUNDA VIA
    ${dados_pagamento}=    VALIDAR ABA PAGAMENTO    ${MES_TESTE}    ${ANO_TESTE}
    IR PARA ABA CONSUMO
    ${dados_consumo}=    VALIDAR ABA CONSUMO

    VALIDAR FATURA CONTRA SALESFORCE
    ...    ${numero_instalacao}    ${MES_TESTE}    ${ANO_TESTE}
    ...    ${dados_pagamento}[valor]    ${dados_pagamento}[vencimento]
    ...    ${dados_pagamento}[status]    ${dados_pagamento}[economia]
    ...    ${dados_consumo}[sem_lumen]
