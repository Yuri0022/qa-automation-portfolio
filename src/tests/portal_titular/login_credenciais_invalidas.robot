*** Settings ***
Documentation      Testes de caminho negativo do login: valida as mensagens de
...                erro exibidas para e-mail não cadastrado e para senha
...                incorreta, e confirma que o login não é concluído em
...                nenhum dos dois casos. Equivalente web de
...                src/tests/app_mobile/login_credenciais_invalidas.robot —
...                mesmas mensagens de erro do backend.
Library            ../../../load_env.py
Resource           ../../common/generic-keywords.resource
Resource           ../../keywords/portal-titular-keywords.resource
Test Teardown      ENCERRAR TESTE PORTAL DO TITULAR

*** Test Cases ***
Login com email não cadastrado mostra mensagem correta
    [Tags]    REGRESSAO    NEGATIVO
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    REALIZAR LOGIN PORTAL DO TITULAR    email.que.nao.existe.teste@lumenenergia.com.br    senhaqualquer123
    VALIDAR MENSAGEM DE ERRO DE LOGIN    Usuário não encontrado. Verifique se o email está correto.

Login com senha incorreta mostra mensagem correta
    [Tags]    REGRESSAO    NEGATIVO
    ACESSAR PAGINA %{URL_PORTAL_TITULAR}
    REALIZAR LOGIN PORTAL DO TITULAR    %{EMAIL_PORTAL_TITULAR}    senhaTotalmenteErrada999
    VALIDAR MENSAGEM DE ERRO DE LOGIN    Email ou senha incorretos. Verifique suas credenciais.
