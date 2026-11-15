import json
from http.server import BaseHTTPRequestHandler, HTTPServer

# Produtos de exemplo, guardados na memória do programa.
PRODUTOS = [
    {"id": 1, "nome": "Caderno", "preco": 15.00},
    {"id": 2, "nome": "Caneta", "preco": 3.00},
]


class ProdutosHandler(BaseHTTPRequestHandler):
    # Executa quando alguém faz uma solicitação GET.
    def do_GET(self):
        if self.path == "/produtos":
            dados = PRODUTOS
            status = 200
        elif self.path == "/health":
            dados = {"status": "ok"}
            status = 200
        else:
            dados = {"erro": "Caminho nao encontrado"}
            status = 404

        # Converte os dados para JSON e envia a resposta.
        resposta = json.dumps(dados).encode("utf-8")

        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(resposta)


# Inicia a API na porta 8001.
if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8001), ProdutosHandler).serve_forever()