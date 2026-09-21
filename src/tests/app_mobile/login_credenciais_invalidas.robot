*** Settings ***
Documentation    Testes de caminho negativo do login: valida as mensagens de
...              erro exibidas para email não cadastrado e para senha
...              incorreta, e confirma que o login não é concluído em
...              nenhum dos dois casos.
Library            ../../../load_env.py
Resource    ../../keywords/app-mobile-keywords.resource
Test Teardown    FECHAR APLICATIVO

*** Test Cases ***
LOGIN COM EMAIL NAO CADASTRADO MOSTRA MENSAGEM CORRETA
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    email.que.nao.existe.teste@lumenenergia.com.br    senhaqualquer123
    VALIDAR MENSAGEM DE ERRO DE LOGIN    Usuário não encontrado. Verifique se o email está correto.

LOGIN COM SENHA INCORRETA MOSTRA MENSAGEM CORRETA
    ABRIR APLICATIVO LUMEN
    ACEITAR PERMISSAO DE NOTIFICACAO SE APARECER
    IR PARA TELA DE LOGIN
    FAZER LOGIN    %{EMAIL_APP_MOBILE}    senhaTotalmenteErrada999
    VALIDAR MENSAGEM DE ERRO DE LOGIN    Email ou senha incorretos. Verifique suas credenciais.
