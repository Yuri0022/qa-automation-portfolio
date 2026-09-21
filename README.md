## Executar o comando 

```
pip install -r requirements-dev.txt
```

## Variáveis de ambiente (.env)

O projeto lê as configurações de um arquivo `.env` na raiz (não versionado).
Além das URLs e credenciais, há uma variável opcional:

- `BROWSER_EXECUTABLE_PATH` — caminho de um navegador instalado no sistema
  (ex.: `C:/Program Files/Google/Chrome/Application/chrome.exe`). Se **vazia
  ou ausente**, os testes usam o chromium empacotado do Playwright (padrão,
  recomendado em CI). Defina-a apenas em máquinas onde o chromium empacotado
  não inicia — por exemplo, quando falta a dependência `msvcp140_1.dll`
  (Microsoft Visual C++ Redistributable) no Windows.

### Salesforce (`src/API`, `src/keywords/salesforce-keywords.resource`)

- `SALESFORCE_CLIENT_ID`, `SALESFORCE_CLIENT_SECRET`, `SALESFORCE_AUTH_URL` —
  credenciais da Connected App (fluxo OAuth Client Credentials).

### Portal dos Parceiros (`src/tests/portal_parceiros`, `src/tests/esteira_digital`)

- `URL_PORTAL`, `EMAIL_PORTAL` / `PASSWORD_PORTAL` — conta de teste de um
  perfil comercial.
- `EMAIL_PORTAL_INDIRETO` / `PASSWORD_PORTAL_INDIRETO` — conta de teste de um
  segundo perfil comercial, necessária porque algumas regras de negócio só
  se aplicam a esse perfil.

#### Testes de fronteira em regra de negócio por consumo (exploratório)

Um dos fluxos de contratação tem uma regra de validação baseada no consumo de
energia (kWh) do cadastro, com comportamento diferente conforme o perfil
comercial. Os detalhes específicos de negócio (limiar exato, nomes de campos
internos) foram omitidos deste README por serem informação proprietária do
cliente — mas a metodologia usada pra investigar e confirmar essa regra
ilustra bem o tipo de teste de fronteira/exploratório que gosto de fazer:

- **Investigação de agregação**: com múltiplas contas de energia vinculadas
  ao mesmo cadastro, confirmei que a regra soma o consumo de todas as contas
  antes de decidir — não considera só a primeira cadastrada.
- **Bisseção do limiar exato**: sem documentação prévia do valor exato do
  limite, encontrei-o por bisseção binária — testando valores cada vez mais
  próximos até confirmar a fronteira com precisão de 1 kWh (o valor
  imediatamente abaixo aprova, o valor exato e qualquer acima reprovam).
- **"Gotcha" de unidade**: o valor de consumo exibido na tela para o usuário
  final não é o mesmo valor usado internamente pela regra (havia um fator de
  desconto aplicado só na exibição) — recalibrar os testes contra o valor
  bruto (não o exibido) foi essencial pra não reportar um falso positivo.

#### Consumo customizável nas faturas de teste (`src/services/pdf_service.py`)

O template de fatura (`src/templates/template-fatura-generica.jpg`) tem uma tabela
de histórico de consumo fixa na imagem — sem sobrescrevê-la, toda fatura
gerada por `CRIAR FATURA CLIENTE PF` resulta sempre no mesmo consumo,
impossibilitando testar regras de negócio por faixa de consumo (como a
descrita acima). O argumento opcional `consumo_mensal_kwh` sobrescreve essa
coluna com o valor desejado (mesmo texto repetido nas 13 linhas — suficiente
para variar o consumo médio calculado pelo portal). Compatível com todo
código existente: sem esse argumento, o comportamento não muda.

### Portal do Titular (`src/tests/portal_titular`)

Testes do Portal do Titular (portal web, `robotframework-browser`/Playwright). Cobertura
espelhada da suíte do app mobile (`src/tests/app_mobile`) — mesmo backend, mesmas
mensagens de erro e regras de negócio na maioria dos fluxos.

Variáveis de ambiente:

- `URL_PORTAL_TITULAR` — URL do Portal do Titular (ex.: `https://portal-hml.lumenenergia.com.br/`)
- `EMAIL_PORTAL_TITULAR` / `PASSWORD_PORTAL_TITULAR` — credenciais de uma conta de teste PF de
  **Minas Gerais**
- `CPF_TITULAR` — CPF (com ou sem formatação) do titular usado para login, necessário para
  localizar o Contact correspondente no Salesforce e validar que a alteração de e-mail persistiu
- `PORTAL_EMAIL_TESTE` — opcional, e-mail usado no teste de alteração cadastral com sucesso
  (tem um default gerado por Faker se não definida)
- `EMAIL_PORTAL_TITULAR_EXPANSAO` / `PASSWORD_PORTAL_TITULAR_EXPANSAO` — credenciais de uma conta
  de teste PF de **expansão** (qualquer estado fora de MG — o comportamento é o mesmo entre eles),
  com pelo menos 2 CPF/CNPJ vinculados e pelo menos 1 deles com fatura em aberto
- `CPF_TITULAR_EXPANSAO` — reservado para uma futura validação via Salesforce equivalente à de
  `dados_cadastrais.robot`, ainda não implementada para o segmento de expansão

#### Segmentos: Minas Gerais x Expansão

O Portal do Titular tem dois comportamentos de conta bem diferentes, cobertos por arquivos
separados (mesmo backend, resource de keywords compartilhado):

- **Minas Gerais** (`EMAIL_PORTAL_TITULAR`): um único CPF/CNPJ e uma única instalação por login,
  conta unificada mostrando só a fatura da Lumen.
- **Expansão** (`EMAIL_PORTAL_TITULAR_EXPANSAO`, arquivos `expansao_*.robot`): a distribuidora
  local emite conta própria, separada da Lumen, mesmo em conta "unificada" — o portal oferece um
  link dedicado para baixar essa segunda conta em PDF ("Visualizar conta da `<distribuidora>`"), e
  o modal de pagamento avisa para não pagar as duas (duplicidade). Login pode pedir seleção de
  CPF/CNPJ vinculado ("Com qual você deseja seguir?") quando há mais de um vínculo na conta, com
  um seletor "Trocar Perfil" para alternar depois. Um mesmo perfil pode ter várias instalações
  vinculadas (uma conta de teste tinha 6) — `OBTER NUMERO DA INSTALACAO`
  sempre pega a primeira da lista.

Arquivos de teste:

| Arquivo | Cobre |
|---|---|
| `login_credenciais_invalidas.robot` | e-mail não cadastrado / senha incorreta |
| `login_sem_conexao.robot` | contexto do navegador offline (`Set Offline`) |
| `indicacao.robot` | banner de indicação na home + link de compartilhamento (WhatsApp) |
| `dados_cadastrais.robot` | alteração de e-mail cadastral, com sucesso e com erro, validado via Salesforce |
| `fatura.robot` | popup de 2ª via (habilitação progressiva Ano/Mês/Gerar) + aba Pagamento |
| `instalacao.robot` | número de instalação via Perfil → Renomear instalação |
| `contas_unificacao.robot` | banner de unificação de contas, validado via Salesforce |
| `contas_historico.robot` | histórico completo de contas |
| `contas_pagamento.robot` | opções de pagamento (Pix copia e cola, código de barras, QR code) |
| `contas_encaminhar.robot` | download do PDF da conta Lumen ("Baixar conta") |
| `indicacao_tab_indicar_amigo.robot` | formulário "Indique um amigo" (habilitação, máscara, validação) |
| `indicacao_tab_compartilhar.robot` | botão "Compartilhar" da aba Indicação |
| `indicacao_tab_faq.robot` | "Como funciona o Rede Lumen+?" |
| `indicacao_tab_chave_pix.robot` | navegação até "Alterar chave pix" (não submete dados) |
| `expansao_login.robot` | seleção de CPF/CNPJ vinculado no login + "Trocar Perfil" |
| `expansao_contas.robot` | download do PDF da distribuidora + aviso de duplicidade de pagamento + texto do banner de unificação |

`contas_pagamento.robot` e `contas_encaminhar.robot` pulam (`SKIP`) automaticamente quando a
conta configurada não tem fatura em aberto no momento — isso é esperado para MG na maioria das
execuções; a lógica em si já foi verificada contra uma conta de expansão com fatura real.

#### ⚠️ Limitações conhecidas

- **Aba "Consumo" da 2ª via**: em algumas execuções manuais ficou travada num
  spinner infinito. `IR PARA ABA CONSUMO` só confirma a navegação, sem validar
  os valores exibidos — investigar antes de fortalecer essa validação.
- **Persistência de e-mail inválido**: `dados_cadastrais.robot` inclui uma
  validação via Salesforce especificamente porque, durante o desenvolvimento
  destes testes, uma tentativa de e-mail inválido chegou a persistir no
  Contact mesmo exibindo a mensagem de erro na tela — o que derrubou o login
  da conta de teste. Se você tocar nesse teste, não remova essa validação.
- **Tela "Dados cadastrais" muda com frequência**: já foi um campo de e-mail
  direto, depois virou uma lista de contatos colapsados (cada um com
  nome/e-mail/telefone, expandidos por um botão sem ícone/svg identificável —
  ver `ACESSAR DADOS CADASTRAIS` no resource). Se este teste voltar a quebrar
  em "aguardando input de e-mail", é provável que o layout tenha mudado de
  novo — inspecionar a tela real antes de tentar corrigir o locator às cegas.
- **Regex em `Evaluate`/`Should Match Regexp` dentro deste resource**: sempre usar `\\d`, `\\s`,
  `\\w` (barra dupla) no código-fonte, nunca `\d`/`\s`/`\w` (barra simples) — o Robot Framework
  remove uma camada de escape antes do valor chegar no regex, então uma barra simples vira a letra
  solta (`\d` → `d`) e o regex nunca casa. Já causou bugs silenciosos em pelo menos 3 keywords
  diferentes neste arquivo.

### Radar (`src/tests/radar`)

Cadastro de empresas parceiras que vendem o produto Lumen e recebem retorno
financeiro ("Radar"). Existem dois caminhos de cadastro, ambos usando o
**mesmo formulário de 3 etapas** (Empresa → Endereço → Financeiro) e o
**mesmo endpoint** (`POST /api/v1/Radar/Register`):

- **Deslogado** (público, sem conta): `https://parceiro-dev.lumenenergia.com.br/register-radar-forms/`
- **Logado**, dentro do Portal dos Parceiros: `.../register-radar/` — usa as
  mesmas variáveis `URL_PORTAL` / `EMAIL_PORTAL` / `PASSWORD_PORTAL` do Portal
  de Parceiros. Tem um botão extra, "Abrir lista de CNAE's disponíveis para
  cadastro", que o caminho deslogado não tem, e o sucesso do cadastro se
  comporta diferente entre os dois (ver achados abaixo).

O progresso do formulário é salvo no `localStorage` (chave
`partnerRegisterState`: versão, etapa atual e valores de todos os campos) —
fechar a aba e abrir de novo na mesma URL restaura tanto os valores já
digitados quanto a etapa exata em que o usuário parou (`persistencia_localstorage.robot`).

#### ⚠️ Achados importantes

- **Feedback de sucesso difere entre os dois caminhos** (achado corrigido
  numa revisão posterior deste documento — a primeira versão dizia,
  incorretamente, que nenhum dos dois caminhos dava feedback):
  - **Deslogado**: a API retorna 201 (`accountId`/`contactId`, Account +
    Contact criados de verdade no Salesforce), mas a tela **não mostra
    nenhuma confirmação** — o formulário só volta ao estado vazio da etapa
    "Empresa" em silêncio (confirmado esperando até 10s). Os testes desse
    caminho validam a resposta da API + a criação real no Salesforce
    (`VALIDAR CADASTRO RADAR CRIADO NO SALESFORCE`), não uma mensagem de tela.
  - **Logado**: redireciona (client-side, ~2s de atraso — esperar antes de
    checar a tela) para `/radar-register-completed/`, mostrando "Acesso
    disponível após assinatura" e avisando que o login/senha do novo parceiro
    só são enviados após a assinatura do termo pela pessoa indicada. Validado
    por `VALIDAR TELA DE CADASTRO RADAR CONCLUIDO`.
  - Nos dois caminhos, o erro de duplicidade (e-mail/CNPJ já cadastrado) **é
    exibido normalmente** (banner vermelho no topo: "Dados já pertencentes a
    um contato Radar.").
- **Navegar pro caminho logado exige esperar a sessão gravar**: navegar direto
  pra `.../register-radar/` (via `Go To`) logo demais após o login pode
  redirecionar de volta pro login — não é bug do produto, é condição de
  corrida: o token (localStorage, chave `token`) ainda não tinha sido gravado
  no instante da navegação. `IR PARA CADASTRO RADAR LOGADO` espera o token
  existir antes de navegar (`TOKEN DE SESSAO DEVE EXISTIR`) em vez de usar um
  `Sleep` fixo.
- **Texto de botão quebrado em múltiplos text nodes**: `contains(text(), ...)`
  falha silenciosamente (timeout, elemento "não encontrado" mesmo visível na
  tela) em botões como "Voltar" e "Anexar Cartão CNPJ" — o texto vem
  fragmentado em mais de um text node. Usar `contains(., ...)` (pega texto de
  todos os descendentes) em vez de `contains(text(), ...)` nesses casos.
- **Apóstrofo curvo, não reto**: o título do modal de CNAE's usa apóstrofo
  curvo (`’`, U+2019), não o reto (`'`, U+0027) — um locator com `text=` exato
  incluindo esse caractere nunca casa. Ancorar em um trecho sem apóstrofo
  (ex.: `contains(text(),'Confira os CNAE')`) evita o problema.

#### Caminhos de exceção (`validacao_dados_invalidos.robot`)

Cobre dados inválidos/faltantes nas 3 etapas do formulário, sempre pelo
caminho deslogado (validação é do próprio componente React, compartilhado
pelos dois caminhos). Achados confirmados durante o desenvolvimento:

- **"Nome da empresa", "Razão Social" e "Nome do responsável"** exigem pelo
  menos duas palavras — um valor de uma palavra só é rejeitado com "Não
  permitido nome com apenas um termo." nos três campos.
- **CNPJ e CPF (Documento do responsável)** são validados pelo dígito
  verificador de verdade, não só pela máscara/formato.
- **E-mail e upload de arquivo em formato errado** só são validados ao tentar
  avançar/anexar (a tela permanece na etapa e mostra um toast) — não são
  validados enquanto se digita, diferente de CNPJ/CPF/telefone.
- **CEP inexistente** não preenche o endereço automaticamente e impede
  avançar, mas não mostra uma mensagem de erro explícita.
- **Mensagem de upload rejeitado tem o mesmo bug de text node fragmentado**
  do item acima ("Voltar"/"Anexar Cartão CNPJ"): "Erro ao anexar documento do
  CNPJ: Formato .txt não permitido." nunca casa com `contains(text(),...)`
  (confirmado em diagnóstico repetido 3x, com o botão "Avançar" corretamente
  `disabled` nas 3 tentativas — a validação funciona, só o locator estava
  errado). Corrigido com `Get Element Count` sobre `contains(.,'permitido')`
  em vez de `Wait For Elements State` com `contains(text(),...)`.

### App mobile (`src/tests/app_mobile`)

Testes do app do cliente (Portal do Cliente, Android) via Appium/UiAutomator2.

Pré-requisitos, além do `pip install -r requirements-dev.txt`:

- Android Studio + SDK + um emulador criado (AVD Manager)
- Appium Server (`npm install -g appium && appium driver install uiautomator2`),
  rodando (`appium`) antes de executar os testes
- Emulador ligado com o app já instalado (Play Store)

Variáveis de ambiente:

- `EMAIL_APP_MOBILE`, `PASSWORD_APP_MOBILE` — credenciais da conta de teste
- Opcionais (têm default para o emulador local padrão; só defina se o seu
  ambiente for diferente):
  - `APPIUM_SERVER_URL` (default `http://127.0.0.1:4723`)
  - `ANDROID_DEVICE_NAME` (default `emulator-5554`)
  - `ANDROID_PLATFORM_VERSION` (default `14`)
  - `APP_MOBILE_PACKAGE` (default `com.lumenfrontendportal`)
  - `APP_MOBILE_ACTIVITY` (default `com.lumenfrontendportal.MainActivity`)
- `ANDROID_HOME` — variável de ambiente do sistema (não do `.env`) apontando
  para o Android SDK; necessária para localizar o `adb`

Executar um teste específico:

```
robot --outputdir results src/tests/app_mobile/login.robot
```

#### ⚠️ Limitação conhecida: ambiente do Salesforce x ambiente do app

O `SALESFORCE_AUTH_URL` configurado nos testes pode apontar para um ambiente
diferente do que o app mobile em teste consulta (ex.: testes contra
homologação, app contra produção). Isso significa que os testes que cruzam
dados do app com o Salesforce (`fatura_salesforce.robot`,
`contas_unificacao.robot`) podem acusar divergência de dados mesmo quando não
há bug — o dado em si é diferente entre os dois ambientes, não desatualizado.

Para validar esses testes de fato contra a mesma fonte que o app usa, aponte
`SALESFORCE_AUTH_URL`/`SALESFORCE_CLIENT_ID`/`SALESFORCE_CLIENT_SECRET` para
uma Connected App do mesmo ambiente que o app consulta. Até lá, uma
divergência nesses testes não deve ser tratada como bug confirmado sem antes
conferir o ambiente.
