# AWS Docker CI/CD Pipeline

Pipeline integrado e automatizado para deploy na AWS, utilizando Node.js, Docker, Terraform e GitHub Actions.

## Arquitetura do Projeto

*   **Aplicação (Node.js):** API em Express servindo uma página estática e rotas auxiliares (`/health` para monitoramento e `/s3-check` para interagir com a AWS).
*   **Container (Docker):** Imagem baseada em Node 18, configurada com Healthcheck nativo e pronta para produção.
*   **Infraestrutura (Terraform):** Provisionamento de recursos na AWS (S3 para armazenamento, Security Groups, e EC2 com Docker e AWS CLI pré-instalados). O state do Terraform é mantido remotamente via backend S3 e DynamoDB.
*   **Automação (GitHub Actions):** Pipeline contínuo acionado em envios para a branch `main`. Ele realiza o build da imagem, push para o Amazon ECR, atualiza a infraestrutura via Terraform e aplica o deploy do novo container diretamente na EC2 através de SSH.

## Execução Local

### Via Node.js
1. Instale as dependências:
```bash
npm install
```
2. Execute a aplicação:
```bash
npm start
```
Acesse `http://localhost:3000`.

### Via Docker
1. Construa a imagem:
```bash
docker build -t app-devops .
```
2. Execute o container:
```bash
docker run -p 3000:3000 app-devops
```
Acesse `http://localhost:3000`.

## Infraestrutura via Terraform

A infraestrutura base do projeto pode ser gerenciada pelo próprio Terraform CLI.

1. Inicialize o diretório de trabalho:
```bash
terraform init
```
2. Aplique as configurações (informe o nome desejado para a criação do novo bucket S3):
```bash
terraform apply -var="bucket_name=NOME_DO_SEU_BUCKET_UNICO"
```
Ao final da execução, o terminal exibirá a variável `ec2_public_ip`, informando o IP público para acesso à máquina recém-criada.

## Deploy Automatizado (CI/CD)

O deploy ocorre de forma automática a cada `push` na branch `main` ou via execução manual (`workflow_dispatch`). O pipeline assume a responsabilidade de construir e versionar a imagem no ECR, validar o provisionamento da infraestrutura com o Terraform e renovar sem conflitos o container em execução na instância EC2.

Para o funcionamento do GitHub Actions, é estritamente necessário configurar as chaves abaixo no repositório:

**Secrets Necessários:**
*   `AWS_KEY`: Access Key ID com as permissões exigidas.
*   `AWS_SECRET`: Secret Access Key.
*   `AWS_REGION`: Região AWS configurada (ex: `us-east-1`).
*   `ECR_REPO`: URI completo do repositório destino no ECR.
*   `ECR_REGISTRY`: Hostname do ECR necessário para o login (ex: `123456789.dkr.ecr.us-east-1.amazonaws.com`).
*   `EC2_KEY`: Conteúdo da chave privada SSH (formato `.pem`) que garante acesso à EC2.

**Variáveis de Ambiente (Variables):**
*   `CONTAINER_NAME`: Nome base para o container rodando na EC2.
*   `HOST_PORT`: Porta host externa exposta na instância.