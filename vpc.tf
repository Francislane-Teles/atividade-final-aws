# Cria a rede principal do projeto na AWS.
resource "aws_vpc" "main" {
  # Usa a faixa de endereços definida em variables.tf.
  cidr_block = var.vpc_cidr

  # Permite que a rede use nomes DNS.
  enable_dns_support = true

  # Permite nomes DNS para recursos da VPC.
  enable_dns_hostnames = true

  # Dá um nome identificável à VPC no painel da AWS.
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Cria uma parte da VPC onde a EC2 poderá ficar.
resource "aws_subnet" "public" {
  # Coloca esta subnet dentro da VPC criada acima.
  vpc_id = aws_vpc.main.id

  # Usa a faixa de endereços da subnet definida em variables.tf.
  cidr_block = var.public_subnet_cidr

  # Solicita um endereço IP público para instâncias lançadas aqui.
  map_public_ip_on_launch = true

  availability_zone = "${var.aws_region}a"

  # Dá um nome à subnet no painel da AWS.
  tags = {
    Name = "${var.project_name}-subnet-publica"
  }
}

# Cria a conexão da VPC com a internet.
resource "aws_internet_gateway" "main" {
  # Conecta o gateway à VPC do projeto.
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Cria uma tabela com instruções de caminho para o tráfego da rede.
resource "aws_route_table" "public" {
  # Esta tabela pertence à VPC do projeto.
  vpc_id = aws_vpc.main.id

  # Define o caminho para destinos fora da VPC.
  route {
    # 0.0.0.0/0 representa qualquer destino IPv4.
    cidr_block = "0.0.0.0/0"

    # Envia esse tráfego pelo Internet Gateway.
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-rotas-publicas"
  }
}

# Faz a subnet usar a tabela de rotas acima.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}