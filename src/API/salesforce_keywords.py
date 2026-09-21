import os
import re

from salesforce_client import SalesforceClient


ROBOT_LIBRARY_SCOPE = "GLOBAL"

_client = None

# "Pago" no app do cliente corresponde a estes valores de Status__c em
# Transacao__c (confirmado com o time: baixas parciais NÃO contam como "Pago").
STATUS_PAGO_VALORES = {"Baixado", "Baixado Externo", "Baixado em Acordo"}

# Regra de negócio do banner de unificação de contas (app do cliente, aba
# Contas), definida em
# UnidadeConsumidoraDoConsorcio__c.FaturaDistribuidoraNaoUnificada__c.
BANNER_UNIFICACAO_POR_STATUS = {
    "Não Unificado": "Sua conta não está unificada.",
    "Unificado": "Sua conta está unificada.",
    "Unificado Especial": "Sua conta está unificada.",
}


def conectar_salesforce():
    global _client

    client_id = os.getenv("SALESFORCE_CLIENT_ID")
    client_secret = os.getenv("SALESFORCE_CLIENT_SECRET")
    auth_url = os.getenv("SALESFORCE_AUTH_URL")

    if not client_id:
        raise ValueError(
            "Variável SALESFORCE_CLIENT_ID não encontrada."
        )

    if not client_secret:
        raise ValueError(
            "Variável SALESFORCE_CLIENT_SECRET não encontrada."
        )

    if not auth_url:
        raise ValueError(
            "Variável SALESFORCE_AUTH_URL não encontrada."
        )

    _client = SalesforceClient(
        client_id=client_id,
        client_secret=client_secret,
        auth_url=auth_url,
    )

    return True


def executar_soql(soql):
    _validar_conexao()
    return _client.query(soql)


def listar_campos_do_objeto(object_name):
    """
    Lista (nome_api, label, tipo) de todos os campos do objeto — útil para
    descobrir o nome de API de um campo a partir do que aparece na UI.
    """
    _validar_conexao()

    descricao = _client.describe_object(object_name)

    return [
        {"nome_api": campo["name"], "label": campo["label"], "tipo": campo["type"]}
        for campo in descricao.get("fields", [])
    ]


def buscar_leads_por_cpf(cpf):
    """
    Retorna todos os Leads cadastrados para o CPF informado, ordenados do
    mais recente para o mais antigo.

    Pode haver mais de um registro: na Lumen é possível existir mais de um
    Lead para o mesmo CPF/CNPJ (ex.: um Lead é recriado após correção de
    dados de um cadastro anterior). Por isso a busca não usa LIMIT 1 e cabe
    a quem consome o resultado decidir qual(is) registro(s) são relevantes.
    """
    _validar_conexao()

    cpf_sem_formatacao = _normalizar_cpf(cpf)

    soql = f"""
        SELECT
            Id,
            Name,
            Email,
            Phone,
            Status,
            CreatedDate,
            CPFCNPJSemFormataco__c
        FROM Lead
        WHERE CPFCNPJSemFormataco__c = '{cpf_sem_formatacao}'
        ORDER BY CreatedDate DESC
    """

    resultado = _client.query(soql)
    registros = resultado.get("records", [])

    if not registros:
        raise AssertionError(
            "Nenhum Lead encontrado no Salesforce para o CPF informado."
        )

    return registros


def buscar_contato_por_cpf(cpf):
    """
    Retorna todos os Contacts cadastrados para o CPF informado, ordenados do
    mais recente para o mais antigo.

    Usado para validar o Portal do Titular (ex.: confirmar que uma alteração
    de e-mail feita no portal persistiu no Salesforce). Assim como Lead e
    Contract, pode haver mais de um Contact para o mesmo CPF.
    """
    _validar_conexao()

    cpf_sem_formatacao = _normalizar_cpf(cpf)

    soql = f"""
        SELECT
            Id,
            Name,
            Email,
            CPFSemFormataco__c
        FROM Contact
        WHERE CPFSemFormataco__c = '{cpf_sem_formatacao}'
        ORDER BY CreatedDate DESC
    """

    resultado = _client.query(soql)
    registros = resultado.get("records", [])

    if not registros:
        raise AssertionError(
            "Nenhum Contact encontrado no Salesforce para o CPF informado."
        )

    return registros


def buscar_contratos_por_cpf(cpf):
    """
    Retorna todos os Contracts (contratos) cadastrados para o CPF informado,
    ordenados do mais recente para o mais antigo.

    Assim como os Leads, um mesmo CPF/CNPJ pode ter vários contratos em
    status diferentes. Retorna a lista (possivelmente vazia); cabe a quem
    consome decidir a validação. Observação: no objeto Contract o campo de
    CPF/CNPJ é 'CPFCNPJSemFormatacao__c' (diferente do Lead, que é
    'CPFCNPJSemFormataco__c').
    """
    _validar_conexao()

    cpf_sem_formatacao = _normalizar_cpf(cpf)

    soql = f"""
        SELECT
            Id,
            Status,
            CPFCNPJSemFormatacao__c
        FROM Contract
        WHERE CPFCNPJSemFormatacao__c = '{cpf_sem_formatacao}'
        ORDER BY CreatedDate DESC
    """

    resultado = _client.query(soql)

    return resultado.get("records", [])


def buscar_transacoes_por_instalacao(numero_instalacao):
    """
    Retorna todas as Transacao__c da instalação informada (app do cliente),
    ordenadas do mais recente para o mais antigo. Pode haver mais de uma
    transação por instalação (uma por mês de referência).
    """
    _validar_conexao()

    soql = f"""
        SELECT FIELDS(ALL)
        FROM Transacao__c
        WHERE Numero_de_instalacao__c = '{numero_instalacao}'
        ORDER BY CreatedDate DESC
        LIMIT 200
    """

    resultado = _client.query(soql)
    registros = resultado.get("records", [])

    if not registros:
        raise AssertionError(
            "Nenhuma Transacao__c encontrada no Salesforce para a instalação informada."
        )

    return registros


def buscar_transacao_por_instalacao_mes_ano(numero_instalacao, mes_referencia, ano):
    """
    Retorna a Transacao__c mais recente da instalação para o mês/ano informado.
    """
    _validar_conexao()

    soql = f"""
        SELECT Id, MesReferenciaNome__c, Ano__c, nValor__c, Status__c,
               dtVencimento__c, MonthlySavings__c, Valor_EnerDist__c
        FROM Transacao__c
        WHERE Numero_de_instalacao__c = '{numero_instalacao}'
        AND MesReferenciaNome__c = '{mes_referencia}'
        AND Ano__c = {int(ano)}
        ORDER BY CreatedDate DESC
        LIMIT 5
    """

    resultado = _client.query(soql)
    registros = resultado.get("records", [])

    if not registros:
        raise AssertionError(
            f"Nenhuma Transacao__c encontrada para a instalação {numero_instalacao} "
            f"em {mes_referencia}/{ano}."
        )

    return registros[0]


def validar_fatura_contra_salesforce(
    numero_instalacao,
    mes_referencia,
    ano,
    valor_ui,
    vencimento_ui,
    status_ui,
    economia_ui,
    sem_lumen_ui,
):
    """
    Busca a Transacao__c correspondente e compara contra os valores exibidos
    no app do cliente (aba "Gerar 2ª via da fatura"). Aceita as strings
    "cruas" extraídas da tela (ex: frases completas com o valor embutido) —
    a extração do número/data é feita aqui via regex. Lança AssertionError
    com todas as divergências encontradas (não para na primeira).
    """
    transacao = buscar_transacao_por_instalacao_mes_ano(
        numero_instalacao, mes_referencia, ano
    )
    erros = []

    valor_api = transacao.get("nValor__c")
    valor_ui_num = _extrair_valor_moeda(valor_ui)
    if valor_api is None or round(float(valor_api), 2) != round(valor_ui_num, 2):
        erros.append(
            f"Valor: app={valor_ui_num} vs Salesforce nValor__c={valor_api}"
        )

    vencimento_api = transacao.get("dtVencimento__c")  # formato "AAAA-MM-DD"
    vencimento_ui_iso = _extrair_data_iso(vencimento_ui)
    if vencimento_api != vencimento_ui_iso:
        erros.append(
            f"Vencimento: app={vencimento_ui_iso} vs Salesforce dtVencimento__c={vencimento_api}"
        )

    status_api = transacao.get("Status__c")
    status_ui_normalizado = status_ui.strip().lower()
    if status_ui_normalizado == "pago" and status_api not in STATUS_PAGO_VALORES:
        erros.append(
            f"Status: app='Pago' mas Salesforce Status__c={status_api!r} "
            f"(esperado um de {sorted(STATUS_PAGO_VALORES)})"
        )

    economia_api = transacao.get("MonthlySavings__c")
    economia_ui_num = _extrair_valor_moeda(economia_ui)
    if economia_api is None or round(float(economia_api), 2) != round(economia_ui_num, 2):
        erros.append(
            f"Economia: app={economia_ui_num} vs Salesforce MonthlySavings__c={economia_api}"
        )

    # "Sem a Lumen você pagaria" = nValor__c + MonthlySavings__c. Valor_EnerDist__c
    # é um campo LEGADO: só é preenchido em transações antigas (~2021, quando
    # MonthlySavings__c ainda não existia); em transações atuais fica 0.
    if valor_api is not None and economia_api is not None:
        sem_lumen_api = round(float(valor_api) + float(economia_api), 2)
        sem_lumen_ui_num = _extrair_valor_moeda(sem_lumen_ui)
        if sem_lumen_api != round(sem_lumen_ui_num, 2):
            erros.append(
                f"Sem a Lumen: app={sem_lumen_ui_num} vs calculado "
                f"(nValor__c + MonthlySavings__c)={sem_lumen_api}"
            )

    if erros:
        raise AssertionError(
            "Divergências entre app e Salesforce:\n" + "\n".join(erros)
        )

    return transacao


def buscar_unidade_consumidora_por_instalacao(numero_instalacao):
    """
    Retorna a UnidadeConsumidoraDoConsorcio__c da instalação informada.
    """
    _validar_conexao()

    soql = f"""
        SELECT Id, NumeroInstalacao__c, FaturaDistribuidoraNaoUnificada__c
        FROM UnidadeConsumidoraDoConsorcio__c
        WHERE NumeroInstalacao__c = '{numero_instalacao}'
        LIMIT 5
    """

    resultado = _client.query(soql)
    registros = resultado.get("records", [])

    if not registros:
        raise AssertionError(
            f"Nenhuma UnidadeConsumidoraDoConsorcio__c encontrada para a "
            f"instalação {numero_instalacao}."
        )

    return registros[0]


def validar_banner_unificacao_contra_salesforce(numero_instalacao, texto_banner_ui):
    """
    Compara o texto do banner de unificação exibido no app do cliente (aba
    Contas) contra a regra de negócio definida por
    FaturaDistribuidoraNaoUnificada__c.
    """
    registro = buscar_unidade_consumidora_por_instalacao(numero_instalacao)
    status = registro.get("FaturaDistribuidoraNaoUnificada__c")

    esperado = BANNER_UNIFICACAO_POR_STATUS.get(status)
    if esperado is None:
        raise AssertionError(
            f"Valor inesperado de FaturaDistribuidoraNaoUnificada__c: {status!r}"
        )

    texto_ui_normalizado = texto_banner_ui.strip()
    if texto_ui_normalizado != esperado:
        raise AssertionError(
            f"Banner de unificação incorreto: Salesforce diz "
            f"FaturaDistribuidoraNaoUnificada__c={status!r} (banner esperado: "
            f"{esperado!r}), mas o app mostra {texto_ui_normalizado!r}."
        )

    return True


def _extrair_valor_moeda(texto):
    """Extrai um número de uma string tipo 'R$ 1.234,56' ou uma frase que a contenha."""
    match = re.search(r"R\$\s*([\d.,]+)", texto)
    if not match:
        raise ValueError(f"Não foi possível extrair um valor monetário de: {texto!r}")
    bruto = match.group(1).replace(".", "").replace(",", ".")
    return float(bruto)


def _extrair_data_iso(texto):
    """Extrai uma data DD/MM/AAAA de uma string e retorna no formato AAAA-MM-DD."""
    match = re.search(r"(\d{2})/(\d{2})/(\d{4})", texto)
    if not match:
        raise ValueError(f"Não foi possível extrair uma data de: {texto!r}")
    dia, mes, ano = match.groups()
    return f"{ano}-{mes}-{dia}"


def _normalizar_cpf(cpf):
    cpf_sem_formatacao = (
        str(cpf)
        .replace(".", "")
        .replace("-", "")
        .replace("/", "")
        .strip()
    )

    if not cpf_sem_formatacao.isdigit():
        raise ValueError(
            "O CPF informado possui caracteres inválidos."
        )

    if len(cpf_sem_formatacao) not in (11, 14):
        raise ValueError(
            "O CPF/CNPJ informado deve possuir 11 ou 14 dígitos."
        )

    return cpf_sem_formatacao


def _validar_conexao():
    if _client is None:
        raise RuntimeError(
            "Salesforce não conectado. "
            "Execute CONECTAR SALESFORCE primeiro."
        )
