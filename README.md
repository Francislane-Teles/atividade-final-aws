# Atividade final AWS — e-commerce

Projeto de estudo para executar duas APIs na AWS: Produtos e Pedidos.

## Como o projeto funciona

As duas APIs foram escritas em Python e executadas em uma instância
EC2 na AWS. A infraestrutura foi criada com Terraform.

1. **Consultar produtos — `GET /produtos`:** a API retorna em JSON
   uma lista de produtos de exemplo definida no código.
2. **Enviar um pedido — `POST /pedidos`:** a API recebe o ID do
   produto e a quantidade, envia uma mensagem à fila SQS e responde
   com HTTP `202`, indicando que o pedido foi aceito para processamento.
3. **Processar o pedido:** a Lambda lê a mensagem da fila SQS e
   registra o processamento no CloudWatch Logs.

Nesta atividade, os produtos eram exemplos e os pedidos não foram
salvos em banco de dados.

## Serviços utilizados

- EC2: computador na AWS onde as APIs vão funcionar.
- SQS: fila que recebe as mensagens dos pedidos.
- Lambda: função que processa as mensagens.
- CloudWatch Logs: guarda os registros da execução.
- IAM: controla as permissões de acesso aos serviços.
- VPC: rede onde ficará a EC2.

## Terraform

O Terraform usa os arquivos `.tf` para criar a infraestrutura na AWS.

- `terraform plan`: mostra as alterações previstas.
- `terraform apply`: executa as alterações.
- `terraform destroy`: remove os recursos do projeto.

## Resultados e evidências

A infraestrutura foi implantada na AWS com Terraform. A API de
produtos retornou a lista em JSON, e a API de pedidos respondeu
com HTTP 202 ao aceitar um pedido e enviar a mensagem para a fila SQS.
A Lambda processou a mensagem, e o registro apareceu no CloudWatch Logs.

- [Consulta de produtos](evidencias/api-produtos-aws.png)
- [Envio de um pedido](evidencias/api-pedidos-aws.png)
- [Processamento do pedido pela Lambda](evidencias/cloudwatch-lambda.png)
- [Remoção dos recursos](evidencias/terraform-destroy.png)

Após os testes, os recursos da atividade foram removidos com
`terraform destroy`. As APIs ficaram indisponíveis após a remoção.
