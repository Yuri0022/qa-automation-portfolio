import random

def gerar_cnpj(formatado=False):
    cnpj = [random.randint(0, 9) for _ in range(8)] + [0, 0, 0, 1]

    # Primeiro dígito verificador
    pesos_1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    soma = sum(cnpj[i] * pesos_1[i] for i in range(12))
    resto = soma % 11
    cnpj.append(0 if resto < 2 else 11 - resto)

    # Segundo dígito verificador
    pesos_2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    soma = sum(cnpj[i] * pesos_2[i] for i in range(13))
    resto = soma % 11
    cnpj.append(0 if resto < 2 else 11 - resto)

    cnpj_str = ''.join(map(str, cnpj))

    if str(formatado).lower() == "true":
        return f"{cnpj_str[:2]}.{cnpj_str[2:5]}.{cnpj_str[5:8]}/{cnpj_str[8:12]}-{cnpj_str[12:]}"

    return cnpj_str
