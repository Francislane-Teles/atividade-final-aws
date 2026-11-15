# Cria a fila que receberá os pedidos enviados pela API.
resource "aws_sqs_queue" "pedidos" {
  # Nome da fila exigido 
  name = "pedidos-a-processar"

  # Identifica a qual projeto esta fila pertence.
  tags = {
    Project = var.project_name
  }
}