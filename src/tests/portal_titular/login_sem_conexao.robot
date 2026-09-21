*** Settings ***
Documentation      Testa o comportamento do login sem conexão de rede (contexto do
...                navegador colocado offline): confirma a mensagem de erro de
...                conexão e que o login não é concluído. A rede é reativada no
...                teardown mesmo se o teste falhar — senão o contexto fica
...                offline para os testes seguintes. Equivalente web de
...                src/tests/app_mobile/login_sem_conexao.robot.
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-titular-keywords.resource
Test Teardown      Run Keywords    REATIVAR CONEXAO DE REDE    AND    ENCERRAR TESTE PORTAL DO TITULAR

*** Test Cases ***
Login sem conexão mostra erro de rede
    [Tags]    REGRESSAO    NEGATIVO
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    DESATIVAR CONEXAO DE REDE
    REALIZAR LOGIN PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR}    %{PASSWORD_PORTAL_TITULAR}
    VALIDAR MENSAGEM DE ERRO DE LOGIN    Erro de conexão. Verifique sua internet e tente novamente.
