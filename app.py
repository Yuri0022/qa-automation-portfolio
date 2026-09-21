from pathlib import Path
import subprocess
import sys
import threading
import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageDraw, ImageTk


window = tk.Tk()
window.title("Testes Automatizados Lumen")
window.geometry("800x400")

# 1. Carregar e redimensionar a imagem de fundo para preencher a janela
fundo = Image.open("src/assets/background.jpg").resize((800, 400))

# 2. Carregar a logo e redimensionar mantendo a proporção
logo = Image.open("src/assets/marca_lumen.png")
largura_logo = 150
altura_logo = int(logo.height * (largura_logo / logo.width))
logo = logo.resize((largura_logo, altura_logo))

# 3. Posicionar a logo no canto inferior direito, com margem de 20px
margem = 20
x = 800 - largura_logo - margem
y = 400 - altura_logo - margem
fundo.paste(logo, (x, y), logo)  # usa o próprio logo (RGBA) como máscara de transparência

# 4. Descobrir dinamicamente as seções a partir das pastas em src/tests
pasta_tests = Path("src/tests")
secoes = sorted([p for p in pasta_tests.iterdir() if p.is_dir()], key=lambda p: p.name)

# 5. Desenhar título + linha divisória de cada seção diretamente na imagem de fundo
desenho = ImageDraw.Draw(fundo)
altura_disponivel = 400 - 40
altura_por_secao = altura_disponivel // len(secoes)
y_atual = 30

for pasta in secoes:
    titulo = pasta.name.replace("_", " ").title()
    desenho.text((30, y_atual), titulo, fill="white")
    desenho.line((30, y_atual + 25, 770, y_atual + 25), fill="white", width=2)
    y_atual += altura_por_secao

# 6. Converter para um formato que o Tkinter entende
imagem_final = ImageTk.PhotoImage(fundo)

# 7. Exibir a imagem composta cobrindo toda a janela
label_fundo = tk.Label(window, image=imagem_final)
label_fundo.place(x=0, y=0, relwidth=1, relheight=1)

# 8. Controle para permitir apenas um teste em execução por vez
estado_execucao = {"em_andamento": False}


def executar_teste(caminho_robot, botao, texto_original):
    if estado_execucao["em_andamento"]:
        messagebox.showinfo("Aguarde", "Aguarde a execução do teste atual terminar.")
        return

    estado_execucao["em_andamento"] = True
    botao.config(text="Executando...", state="disabled")

    def rodar():
        resultado = subprocess.run(
            [sys.executable, "-m", "robot", "--outputdir", "src/logs", str(caminho_robot)]
        )
        window.after(0, finalizar, resultado.returncode == 0)

    def finalizar(sucesso):
        botao.config(text=f"{texto_original} {' - OK' if sucesso else ' - Falhou'}", state="normal", bg="#008300" if sucesso else "#FD3C1A")
        estado_execucao["em_andamento"] = False

    threading.Thread(target=rodar, daemon=True).start()


# 9. Criar, para cada seção, um botão para cada arquivo .robot encontrado na pasta
y_atual = 30
for pasta in secoes:
    y_botao = y_atual + 40
    for arquivo in sorted(pasta.glob("*.robot")):
        texto_botao = arquivo.stem.replace("_", " ").replace("-", " ").title()
        botao = tk.Button(window, text=texto_botao)
        botao.config(command=lambda a=arquivo, b=botao, t=texto_botao: executar_teste(a, b, t))
        botao.place(x=30, y=y_botao, width=250)
        y_botao += 35
    y_atual += altura_por_secao

window.mainloop()