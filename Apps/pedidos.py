# Converte dados entre Python e JSON.
import json

# Lê configurações fornecidas ao programa pelo ambiente.
import os

# Permite ao Python conversar com serviços da AWS.
import boto3

# Erros previstos na comunicação com a AWS.
from botocore.exceptions import BotoCoreError, ClientError

# Ferramentas para receber solicitações HTTP.
from http.server import BaseHTTPRequestHandler, HTTPServer


# Lê o endereço da fila. Sem configuração, fica vazio.
SQS_QUEUE_URL = os.environ.get("SQS_QUEUE_URL", "")

# Região da AWS: us-east-1 corresponde à Norte da Virgínia.
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")


# Define como a API atende às solicitações.
class PedidosHandler(BaseHTTPRequestHandler):

    # GET consulta se a API está respondendo.
    def do_GET(self):
        if self.path == "/health":
            dados = {"status": "ok", "api": "pedidos"}
            status = 200  # Sucesso.
        else:
            dados = {"erro": "Caminho nao encontrado"}
            status = 404  # Caminho não encontrado.

        # Converte os dados em texto JSON e depois em bytes.
        resposta = json.dumps(dados).encode("utf-8")

        # Envia o código HTTP e os cabeçalhos da resposta.
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()

        # Envia os dados ao cliente.
        self.wfile.write(resposta)

    # POST recebe os dados de um pedido.
    def do_POST(self):

        # Aceita pedidos somente neste caminho.
        if self.path != "/pedidos":
            self.send_error(404)
            return  # Encerra esta solicitação.

        # Tenta ler e verificar os dados recebidos.
        try:
            # Obtém o tamanho dos dados e converte para inteiro.
            tamanho = int(self.headers.get("Content-Length", "0"))

            # Lê os dados e transforma JSON em um objeto Python.
            pedido = json.loads(self.rfile.read(tamanho))

            # Espera dados com nomes e valores, como um dicionário.
            if not isinstance(pedido, dict):
                raise ValueError()

            # Busca o produto e a quantidade.
            produto_id = pedido.get("produto_id")
            quantidade = pedido.get("quantidade")

            # Exige identificador inteiro e positivo.
            if type(produto_id) is not int or produto_id <= 0:
                raise ValueError()

            # Exige quantidade inteira e positiva.
            if type(quantidade) is not int or quantidade <= 0:
                raise ValueError()

        # Responde com erro quando os dados são inválidos.
        except (ValueError, UnicodeDecodeError):
            self.send_error(400, "Pedido invalido")
            return

        # Mostra o pedido imediatamente no terminal.
        # Isso não salva o pedido em um banco de dados.
        print("Pedido recebido:", pedido, flush=True)

        # Sem endereço da fila, confirma apenas o recebimento local.
        if not SQS_QUEUE_URL:
            resultado = {
                "status": "recebido_localmente",
                "pedido": pedido
            }
            status = 200

        else:
            # Com endereço da fila, tenta enviar a mensagem à AWS.
            try:
                # Cria um cliente para acessar a SQS.
                # Boto3 procura as credenciais disponíveis no ambiente.
                # Na EC2, usaremos a identidade IAM associada à máquina.
                sqs = boto3.client("sqs", region_name=AWS_REGION)

                # Envia o pedido como uma mensagem em texto JSON.
                envio = sqs.send_message(
                    QueueUrl=SQS_QUEUE_URL,
                    MessageBody=json.dumps(pedido)
                )

                # Confirma que a SQS aceitou a mensagem.
                # Isso ainda não confirma o processamento pela Lambda.
                resultado = {
                    "status": "enviado_para_sqs",
                    "message_id": envio["MessageId"]
                }
                status = 202  # Aceito para processamento posterior.

            # Trata erros previstos de acesso ou comunicação com a AWS.
            except (BotoCoreError, ClientError) as erro:
                print("Falha ao enviar para SQS:", erro, flush=True)

                resultado = {
                    "erro": "Nao foi possivel enviar para SQS"
                }
                status = 502

        # Converte o resultado para JSON e envia ao cliente.
        resposta = json.dumps(resultado).encode("utf-8")

        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(resposta)


# Inicia o servidor quando executamos este arquivo diretamente.
if __name__ == "__main__":
    print("API de Pedidos iniciada na porta 8002", flush=True)

    # Escuta na porta 8002 e aguarda solicitações.
    HTTPServer(("0.0.0.0", 8002), PedidosHandler).serve_forever()