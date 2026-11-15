# Grupo de regras de acesso da EC2.
resource "aws_security_group" "api" {
  name        = "${var.project_name}-api"
  description = "Acesso HTTP e SSH para a EC2"
  vpc_id      = aws_vpc.main.id

  # Permite que usuários acessem a aplicação pela porta 80.
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite acesso administrativo somente pelo endereço autorizado.
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  # Permite que a EC2 faça conexões de saída.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-api"
  }
}