# Empacota o código Python para enviar à Lambda.
# Configura a Lambda na AWS usando Terraform.
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/processar_pedidos.py"
  output_path = "${path.module}/processar_pedidos.zip"
}

# Cria o local onde aparecerão os registros da execução.
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-processar-pedidos"
  retention_in_days = 7
}

# Descreve a função Lambda na AWS.
resource "aws_lambda_function" "pedidos" {
  function_name = "${var.project_name}-processar-pedidos"

  # Identidade com permissão para ler a fila e escrever logs.
  role = aws_iam_role.lambda.arn

  # Arquivo ZIP que contém nosso código.
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  # Linguagem e função que a AWS executará.
  runtime = "python3.12"
  handler = "processar_pedidos.lambda_handler"

  # Limites de tempo e memória da execução.
  timeout     = 5
  memory_size = 128

  # Aguarda a criação dos logs e das permissões.
  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy.lambda_sqs
  ]
}

# Liga a fila SQS à Lambda.
resource "aws_lambda_event_source_mapping" "pedidos" {
  event_source_arn = aws_sqs_queue.pedidos.arn
  function_name    = aws_lambda_function.pedidos.arn

  # Entrega uma mensagem por execução para facilitar o teste.
  batch_size = 1
  enabled    = true
}