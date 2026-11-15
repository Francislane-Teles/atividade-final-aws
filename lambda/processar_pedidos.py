# Converte o texto JSON da mensagem em dados Python.
import json


# A AWS chama esta função quando entrega mensagens à Lambda.
# event contém as mensagens; context contém informações da execução.
def lambda_handler(event, context):

    # A SQS pode entregar várias mensagens em uma execução.
    for registro in event["Records"]:

        # "body" contém o texto do pedido enviado pela API.
        pedido = json.loads(registro["body"])

        # Mostra um registro que aparecerá no CloudWatch Logs
        # quando esta função for executada na AWS.
        print(json.dumps({
            "acao": "pedido_processado",
            "message_id": registro["messageId"],
            "pedido": pedido
        }))

    # Finaliza normalmente após processar todas as mensagens.
    return {"status": "ok"}