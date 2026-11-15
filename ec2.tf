# Consulta a imagem do sistema operacional Amazon Linux 2023.
# AMI é o modelo usado para iniciar a máquina.
data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Define o computador virtual que executará as duas APIs.
resource "aws_instance" "api" {
  ami           = data.aws_ssm_parameter.amazon_linux.value
  instance_type = var.instance_type

  # Coloca a máquina na subnet pública do projeto.
  subnet_id = aws_subnet.public.id

  # Aplica as regras de acesso HTTP e SSH.
  vpc_security_group_ids = [aws_security_group.api.id]

  # Associa a identidade com permissão de enviar à SQS.
  iam_instance_profile = aws_iam_instance_profile.ec2.name

  # Solicita um endereço para acesso pela internet.
  associate_public_ip_address = true

  # Usa a versão com token do serviço de metadados da EC2.
  metadata_options {
    http_tokens = "required"
  }

  # Configura o disco da máquina.
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # Usa créditos de CPU no modo padrão da t3.micro.
  # Esses créditos são diferentes dos créditos em dólares.
  credit_specification {
    cpu_credits = "standard"
  }

  # Executa um roteiro de instalação no primeiro início.
  # Criaremos esse arquivo no próximo passo.
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    produtos_b64     = filebase64("${path.module}/Apps/produtos.py")
    pedidos_b64      = filebase64("${path.module}/Apps/pedidos.py")
    requirements_b64 = filebase64("${path.module}/Apps/requirements.txt")
    queue_url        = aws_sqs_queue.pedidos.url
    aws_region       = var.aws_region
  })

  # Recria a máquina se mudarmos o roteiro de instalação.
  user_data_replace_on_change = true

  # Aguarda a conexão com a internet e a permissão de envio.
  depends_on = [
    aws_route_table_association.public,
    aws_iam_role_policy.enviar_pedidos
  ]

  tags = {
    Name = "${var.project_name}-ec2"
  }
}