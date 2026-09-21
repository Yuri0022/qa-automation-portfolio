*** Settings ***
Documentation    Testa o comportamento do login sem conexão de rede (wifi e
...              dados móveis desativados no emulador): confirma a mensagem
...              de erro de conexão e que o login não é concluído.
...              A rede é reativada no teardown mesmo se o teste falhar —
...              senão o emulador fica sem internet pros testes seguintes.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    Run Keywords    REATIVAR CONEXAO DE REDE    AND    FECHAR APLICATIVO

*** Test Cases ***
LOGIN SEM CONEXAO MOSTRA ERRO DE REDE
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    DESATIVAR CONEXAO DE REDE
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    %{PASSWORD_APP_MOBILE}
    VALIDAR MENSAGEM DE ERRO DE LOGIN    Erro de conexão. Verifique sua internet e tente novamente.
