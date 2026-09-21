from salesforce_auth import SalesforceAuth
import requests


class SalesforceClient:
    """
    Cliente genérico para consumo da API REST do Salesforce.
    """

    API_VERSION = "v64.0"

    def __init__(self, client_id: str, client_secret: str, auth_url: str):

        auth = SalesforceAuth(
            client_id=client_id,
            client_secret=client_secret,
            auth_url=auth_url,
        )

        token = auth.login()

        self.instance_url = token["instance_url"]

        self.headers = {
            "Authorization": f"Bearer {token['access_token']}",
            "Content-Type": "application/json",
        }

    def query(self, soql: str) -> dict:
        """
        Executa uma consulta SOQL.
        """

        response = requests.get(
            f"{self.instance_url}/services/data/{self.API_VERSION}/query",
            headers=self.headers,
            params={"q": soql},
        )

        response.raise_for_status()

        return response.json()

    def describe_object(self, object_name: str) -> dict:
        """
        Retorna metadados do objeto (campos, labels, tipos, valores de picklist).
        Útil para descobrir o nome de API de um campo a partir do que aparece
        na UI, sem precisar entrar no Setup do Salesforce.
        """

        response = requests.get(
            f"{self.instance_url}/services/data/{self.API_VERSION}/sobjects/{object_name}/describe",
            headers=self.headers,
        )

        response.raise_for_status()

        return response.json()

    def get_object(self, object_name: str, record_id: str) -> dict:
        """
        Busca um registro pelo Id.
        """

        response = requests.get(
            f"{self.instance_url}/services/data/{self.API_VERSION}/sobjects/{object_name}/{record_id}",
            headers=self.headers,
        )

        response.raise_for_status()

        return response.json()

    def create_object(self, object_name: str, payload: dict) -> dict:
        """
        Cria um registro.
        """

        response = requests.post(
            f"{self.instance_url}/services/data/{self.API_VERSION}/sobjects/{object_name}",
            headers=self.headers,
            json=payload,
        )

        response.raise_for_status()

        return response.json()

    def update_object(self, object_name: str, record_id: str, payload: dict) -> bool:
        """
        Atualiza um registro.
        """

        response = requests.patch(
            f"{self.instance_url}/services/data/{self.API_VERSION}/sobjects/{object_name}/{record_id}",
            headers=self.headers,
            json=payload,
        )

        response.raise_for_status()

        return response.status_code == 204

    def delete_object(self, object_name: str, record_id: str) -> bool:
        """
        Remove um registro.
        """

        response = requests.delete(
            f"{self.instance_url}/services/data/{self.API_VERSION}/sobjects/{object_name}/{record_id}",
            headers=self.headers,
        )

        response.raise_for_status()

        return response.status_code == 204
