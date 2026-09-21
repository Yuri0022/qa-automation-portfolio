import os

from PIL import Image
from reportlab.pdfgen import canvas
from reportlab.lib.colors import white, black

# Posicoes (distancia do topo da imagem, em pixels) de cada linha da coluna
# "Cons. kWh" na tabela "Historico de Consumo" do template. O template estatico
# (template-fatura-generica.jpg) traz essa coluna sempre fixa em 6000 kWh/mes -- sem
# sobrescreve-la, toda fatura gerada resulta no mesmo consumo (~5373 kWh
# reportado pelo portal), impossibilitando testar cenarios de consumo
# baixo/alto (ex.: regra de negocio por limite de consumo (kWh)). Coordenadas
# calibradas manualmente sobre o template (grade de referencia sobreposta).
_LINHAS_HISTORICO_CONSUMO_Y = [
    1398, 1420, 1446, 1472, 1498, 1524, 1550,
    1576, 1602, 1628, 1654, 1680, 1706,
]
_COLUNA_CONS_KWH_X = 150
_COLUNA_CONS_KWH_LARGURA = 120


def gerar_pdf(
    numero_instalacao,
    cpf,
    nome,
    endereco,
    referencia,
    vencimento,
    valor,
    classe,
    subclasse,
    tipo_tarifa,
    consumo_mensal_kwh=None,
    arquivo_saida="./src/docs/Fatura-Cliente.pdf"
):
    template = "./src/templates/template-fatura-generica.jpg"

    # Largura e altura de imagem
    largura, altura = Image.open(template).size

    # src/docs/ fica no .gitignore (pasta de saída gerada, não versionada) —
    # num clone novo ela ainda não existe, então o Canvas falharia com
    # FileNotFoundError ao tentar abrir o arquivo dentro dela.
    os.makedirs(os.path.dirname(arquivo_saida), exist_ok=True)

    # Criar PDF com o mesmo tamanho da imagem
    pdf = canvas.Canvas(arquivo_saida, pagesize=(largura, altura))

    # Desenha a imagem ocupando a página inteira
    pdf.drawImage(
        template,
        0,
        0,
        width=largura,
        height=altura
    )

    # Nome
    pdf.setFont("Helvetica-Bold", 18)  
    pdf.drawString(46, altura - 165, nome)

    # CPF
    pdf.setFont("Helvetica", 18)
    pdf.drawString(84, altura - 245, cpf)

    # Numero de instalação 1
    pdf.setFont("Helvetica-Bold", 30)
    pdf.drawString(355, altura - 375, numero_instalacao)

    # Numero de instalação 2
    pdf.setFont("Helvetica", 18)
    pdf.drawString(645, altura - 1808, numero_instalacao)

    # Referente a:
    pdf.setFont("Helvetica-Bold", 30)
    pdf.drawString(700, altura - 180, referencia)

    # Vencimento: #1
    pdf.drawString(910, altura - 180, vencimento)

    # Vencimento: #2
    pdf.setFont("Helvetica", 18)
    pdf.drawString(850, altura - 1808, vencimento)

    # Valor: #1
    pdf.setFont("Helvetica-Bold", 30)
    pdf.drawString(1180, altura - 180, valor)

    # Valor: #2
    pdf.setFont("Helvetica", 18)
    pdf.drawString(1120, altura - 1808, valor)

    # Classe
    pdf.setFillColor(white)
    pdf.setFont("Helvetica-Bold", 20)
    pdf.drawString(185, altura - 460, classe)

    # Subclasse
    pdf.setFillColor(white)
    pdf.setFont("Helvetica-Bold", 20)
    pdf.drawString(460, altura - 460, subclasse)

    # Tipo de tarifa
    pdf.setFillColor(white)
    pdf.setFont("Helvetica-Bold", 20)
    pdf.drawString(710, altura - 460, tipo_tarifa)

    # Historico de Consumo (coluna "Cons. kWh") -- sobrescreve os 13 valores
    # fixos do template com o consumo desejado, quando informado.
    if consumo_mensal_kwh is not None:
        pdf.setFillColor(white)
        pdf.rect(
            _COLUNA_CONS_KWH_X,
            altura - _LINHAS_HISTORICO_CONSUMO_Y[-1] - 10,
            _COLUNA_CONS_KWH_LARGURA,
            (_LINHAS_HISTORICO_CONSUMO_Y[-1] - _LINHAS_HISTORICO_CONSUMO_Y[0]) + 30,
            fill=1,
            stroke=0,
        )

        pdf.setFillColor(black)
        pdf.setFont("Helvetica", 14)
        for y in _LINHAS_HISTORICO_CONSUMO_Y:
            pdf.drawString(178, altura - y, str(consumo_mensal_kwh))

    pdf.save()

    return arquivo_saida