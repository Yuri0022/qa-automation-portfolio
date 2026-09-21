import requests


class SalesforceAuth:
    """
    Responsável apenas por autenticar no Salesforce.
    """

    def __init__(self, client_id: str, client_secret: str, auth_url: str):
        self.client_id = client_id
        self.client_secret = client_secret
        self.token_url = f"{auth_url}/services/oauth2/token"

    def login(self) -> dict:
        """
        Realiza autenticação OAuth Client Credentials.

        Returns:
            dict: Resposta completa contendo access_token, instance_url, etc.
        """

        response = requests.post(
            self.token_url,
            data={
                "grant_type": "client_credentials",
                "client_id": self.client_id,
                "client_secret": self.client_secret,
            },
        )

        response.raise_for_status()

        return response.json()
