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

## Como executar e testar

Com o Terraform instalado e as credenciais da AWS configuradas,
abra o terminal na raiz do repositório e execute:

```bash
terraform init
terraform plan
terraform apply
```

### Acessar a aplicação na EC2

Depois do `terraform apply`, consulte o IP público da instância EC2.
No navegador, abra `http://IP_PUBLICO_DA_EC2/produtos`, substituindo
`IP_PUBLICO_DA_EC2` pelo IP da instância. A resposta é uma lista em JSON.

### Testar o fluxo de pedidos

Substitua `IP_PUBLICO_DA_EC2` pelo IP da instância e execute:

```bash
curl -i -X POST http://IP_PUBLICO_DA_EC2/pedidos \
  -H 'Content-Type: application/json' \
  -d '{"produto_id":1,"quantidade":2}'
```

A resposta esperada é HTTP `202` com um `message_id`. Para confirmar
o processamento, abra o log da função Lambda no CloudWatch Logs
e procure o registro `pedido_processado` com o mesmo `message_id`.

Ao terminar os testes, execute `terraform destroy` para remover
os recursos criados para a atividade.

## Resultados e evidências

A infraestrutura foi implantada na AWS com Terraform. A API de
produtos retornou a lista em JSON, e a API de pedidos respondeu
com HTTP 202 ao aceitar um pedido e enviar a mensagem para a fila SQS.
A Lambda processou a mensagem, e o registro apareceu no CloudWatch Logs.

- [Consulta de produtos](evidencias/api-produtos-aws.png)
- [Envio de um pedido](evidencias/api-pedidos-aws.png)
- [Processamento do pedido pela Lambda](evidencias/cloudwatch-lambda.png)
- [Remoção dos recursos](evidencias/terraform-destroy.png)
- [Mensagem enviada e recebida no SQS](evidencias/sqs-monitoramento.png)
- [Saída do terraform apply](evidencias/terraform-apply.png)

Após os testes, os recursos da atividade foram removidos com
`terraform destroy`. As APIs ficaram indisponíveis após a remoção.
