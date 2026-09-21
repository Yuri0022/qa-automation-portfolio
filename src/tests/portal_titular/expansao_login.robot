*** Settings ***
Documentation      Testes de login específicos de contas de "expansão" (PF fora de
...                MG): seleção de CPF/CNPJ vinculado e troca de perfil. Não existe
...                equivalente hoje na suíte de MG nem na de app mobile — recurso
...                exclusivo de contas com mais de um CPF/CNPJ vinculado ao mesmo
...                login, confirmado.
...
...                Requer as variáveis de ambiente EMAIL_PORTAL_TITULAR_EXPANSAO,
...                PASSWORD_PORTAL_TITULAR_EXPANSAO de uma conta de teste com pelo
...                menos 2 CPF/CNPJ vinculados.
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-titular-keywords.resource
Test Teardown      ENCERRAR TESTE PORTAL DO TITULAR

*** Test Cases ***
Login com múltiplos CPF/CNPJ pede seleção antes de continuar
    [Documentation]    Confirma que a tela "Com qual você deseja seguir?" aparece
    ...    e que escolher um vínculo + confirmar leva à home normalmente.
    [Tags]    REGRESSAO
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    REALIZAR LOGIN PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR_EXPANSAO}    %{PASSWORD_PORTAL_TITULAR_EXPANSAO}
    PULAR ETAPA DE SALVAR ACESSO
    Wait For Elements State    text=Com qual você deseja seguir?    visible    10s

    Click    (//div[contains(text(),'XXX.XXX')])[1]
    Click    //div[text()='Confirmar']
    Wait For Elements State    text=Com qual você deseja seguir?    hidden    10s
    Wait For Elements State    //div[text()='Perfil']    visible    10s

Trocar perfil alterna entre os CPF/CNPJ vinculados
    [Documentation]    Confirma que "Trocar Perfil" realmente muda de contexto —
    ...    não só reabre a mesma tela sem efeito. Usa o número de instalação
    ...    (Perfil → Renomear instalação) como prova de que os dados mudaram.
    [Tags]    REGRESSAO
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    LOGIN NO PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR_EXPANSAO}    %{PASSWORD_PORTAL_TITULAR_EXPANSAO}

    ABRIR MENU DE PERFIL
    IR PARA RENOMEAR INSTALACAO
    ${instalacao_antes}=    OBTER NUMERO DA INSTALACAO
    VOLTAR
    VOLTAR

    TROCAR PERFIL    2

    ABRIR MENU DE PERFIL
    IR PARA RENOMEAR INSTALACAO
    ${instalacao_depois}=    OBTER NUMERO DA INSTALACAO

    Should Not Be Equal As Strings    ${instalacao_antes}    ${instalacao_depois}
    ...    "Trocar Perfil" não mudou o contexto — instalação continua ${instalacao_antes}.
