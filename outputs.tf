# Endereço da API de Produtos.
output "api_produtos_url" {
  value = "http://${aws_instance.api.public_ip}/produtos"
}

# Endereço para enviar pedidos.
output "api_pedidos_url" {
  value = "http://${aws_instance.api.public_ip}/pedidos"
}

# Endereço da fila de pedidos.
output "sqs_queue_url" {
  value = aws_sqs_queue.pedidos.url
}

# Nome do grupo de registros da Lambda.
output "lambda_log_group" {
  value = aws_cloudwatch_log_group.lambda.name
}