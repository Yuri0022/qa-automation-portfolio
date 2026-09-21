import os

from PIL import Image
from reportlab.pdfgen import canvas

def gerar_rg (rg, data_expedicao, nome, pai, mae, naturalidade, data_nascimento, cpf, arquivo_saida='src/docs/rg-verso.pdf'):

    template = 'src/templates/rg-template.png'

    largura, altura = Image.open(template).size

    # src/docs/ fica no .gitignore (pasta de saída gerada, não versionada) —
    # num clone novo ela ainda não existe, então o Canvas falharia com
    # FileNotFoundError ao tentar abrir o arquivo dentro dela.
    os.makedirs(os.path.dirname(arquivo_saida), exist_ok=True)

    pdf = canvas.Canvas(arquivo_saida, pagesize=(largura, altura))

    pdf.drawImage(template, 0, 0, width=largura, height=altura)

    # Registro Geral
    pdf.setFont("Courier", 28)  
    pdf.drawString(150, altura - 75, rg)

    # Data de Expedição
    pdf.setFont("Courier", 28)  
    pdf.drawString(610, altura - 75, data_expedicao)

    # Nome do Lead
    pdf.setFont("Courier", 28)  
    pdf.drawString(62, altura - 145, nome)

    # Nome do pai
    pdf.setFont("Courier", 28)  
    pdf.drawString(62, altura - 217, pai)

    # Nome do mãe
    pdf.setFont("Courier", 28)  
    pdf.drawString(62, altura - 247, mae)

    # Naturalidade
    pdf.setFont("Courier", 28)  
    pdf.drawString(62, altura - 330, naturalidade)

    # Documento Origem
    pdf.setFont("Courier", 28)  
    pdf.drawString(62, altura - 407, naturalidade)

    # Data de nascimento
    pdf.setFont("Courier", 28)  
    pdf.drawString(643, altura - 330, data_nascimento)

    # Cpf
    pdf.setFont("Courier", 28)  
    pdf.drawString(62, altura - 487, cpf)

    pdf.save()

    return arquivo_saida