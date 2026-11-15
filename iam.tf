# Identidade que a EC2 poderá usar.
resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-ec2-role"

  # Permite que o serviço EC2 assuma essa identidade.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Autoriza essa identidade a enviar mensagens à fila do projeto- SQS.
resource "aws_iam_role_policy" "enviar_pedidos" {
  name = "${var.project_name}-enviar-pedidos"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.pedidos.arn
    }]
  })
}

# Permite associar a identidade à EC2 *que criaremos depois*.
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2.name
}

# Cria a identidade que a Lambda poderá usar.
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  # Autoriza o serviço Lambda a assumir essa identidade.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Permite escrever registros no CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.lambda.name

  # Política pronta da AWS para registros básicos da Lambda.
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permite consumir mensagens somente da fila deste projeto.
resource "aws_iam_role_policy" "lambda_sqs" {
  name = "${var.project_name}-lambda-sqs"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"

      Action = [
        "sqs:ReceiveMessage",    # Receber mensagens.
        "sqs:DeleteMessage",     # Remover após sucesso.
        "sqs:GetQueueAttributes" # Consultar informações da fila.
      ]

      Resource = aws_sqs_queue.pedidos.arn
    }]
  })
}