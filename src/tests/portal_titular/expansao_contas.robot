*** Settings ***
Documentation      Testes da aba Contas específicos de contas de "expansão" (PF
...                fora de MG). Diferença principal em relação a MG: a
...                distribuidora local emite conta própria, separada da Lumen —
...                mesmo numa conta "unificada" — e o portal oferece um link
...                dedicado para baixar essa segunda conta em PDF.
...
...                Confirmado contra uma instalação com fatura em
...                aberto de verdade (distribuidora: ENERNORTE RN, no perfil de
...                índice 2 desta conta de teste — o perfil 1
...                está em onboarding, sem faturas). Se a conta de teste mudar,
...                ajustar ${PERFIL_COM_CONTAS} abaixo.
...
...                Requer as mesmas variáveis de expansao_login.robot:
...                EMAIL_PORTAL_TITULAR_EXPANSAO / PASSWORD_PORTAL_TITULAR_EXPANSAO,
...                de uma conta com pelo menos um CPF/CNPJ vinculado que já tenha
...                fatura em aberto.
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-titular-keywords.resource
Test Setup         Login no perfil com contas reais
Test Teardown      ENCERRAR TESTE PORTAL DO TITULAR

*** Variables ***
${PERFIL_COM_CONTAS}    2

*** Keywords ***
Login no perfil com contas reais
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    REALIZAR LOGIN PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR_EXPANSAO}    %{PASSWORD_PORTAL_TITULAR_EXPANSAO}
    PULAR ETAPA DE SALVAR ACESSO
    SELECIONAR CPF OU CNPJ VINCULADO    ${PERFIL_COM_CONTAS}

*** Test Cases ***
Conta em aberto permite baixar o PDF da distribuidora
    [Documentation]    Recurso que não existe no fluxo de MG testado até aqui —
    ...    baixa o PDF da distribuidora local, além do PDF da própria Lumen.
    [Tags]    REGRESSAO
    IR PARA ABA CONTAS
    ${existe}=    CONTA EM ABERTO EXISTE
    IF    not ${existe}
        Skip    Nenhuma conta em aberto no perfil ${PERFIL_COM_CONTAS} no momento — confirme se a conta de teste ainda tem fatura pendente.
    END

    ${distribuidora}=    OBTER NOME DA DISTRIBUIDORA
    Log To Console    Distribuidora exibida: ${distribuidora}
    ${arquivo_distribuidora}=    BAIXAR CONTA DA DISTRIBUIDORA    ${distribuidora}
    Log To Console    ✓ PDF da distribuidora baixado: ${arquivo_distribuidora}

    ${arquivo_lumen}=    BAIXAR CONTA LUMEN
    Log To Console    ✓ PDF da Lumen baixado: ${arquivo_lumen}

Modal de pagamento avisa para não pagar a distribuidora em duplicidade
    [Documentation]    Contas unificadas fora de MG mostram um aviso explícito no
    ...    modal de pagamento: o valor da distribuidora já está incluído na
    ...    fatura da Lumen, então pagar as duas causaria duplicidade.
    [Tags]    REGRESSAO
    IR PARA ABA CONTAS
    ${existe}=    CONTA EM ABERTO EXISTE
    IF    not ${existe}
        Skip    Nenhuma conta em aberto no perfil ${PERFIL_COM_CONTAS} no momento — confirme se a conta de teste ainda tem fatura pendente.
    END
    CLICAR EM PAGAR CONTA
    VALIDAR AVISO DE NAO PAGAR DISTRIBUIDORA

Banner de unificação informa que só a conta da Lumen deve ser paga
    [Documentation]    O texto do banner de unificação nesta conta é diferente do
    ...    usado em MG: além de "está unificada", explicita "apenas a conta de
    ...    luz da Lumen" — reforçando que a distribuidora é paga à parte.
    [Tags]    REGRESSAO
    IR PARA ABA CONTAS
    ${texto_banner}=    OBTER TEXTO DO BANNER DE UNIFICACAO
    Should Contain    ${texto_banner}    unificada
    Wait For Elements State    //*[contains(text(),'apenas a conta de luz da Lumen')]    visible    10s
