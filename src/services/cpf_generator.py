import random

def gerar_cpf(formatado=False):
    cpf = [random.randint(0, 9) for _ in range(9)]

    # Primeiro dígito verificador
    soma = sum(cpf[i] * (10 - i) for i in range(9))
    resto = soma % 11
    cpf.append(0 if resto < 2 else 11 - resto)

    # Segundo dígito verificador
    soma = sum(cpf[i] * (11 - i) for i in range(10))
    resto = soma % 11
    cpf.append(0 if resto < 2 else 11 - resto)

    cpf_str = ''.join(map(str, cpf))

    if str(formatado).lower() == "true":
        return f"{cpf_str[:3]}.{cpf_str[3:6]}.{cpf_str[6:9]}-{cpf_str[9:]}"

    return cpf_str