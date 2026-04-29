# AWS Docker CI/CD Pipeline

Pipeline integrado utilizando Node.js, Docker, Terraform e GitHub Actions para deploy automatizado na AWS (ECR e EC2).

## Arquitetura

*   **Aplicacao:** API Node.js (Express) com rotas e interface em HTML.
*   **Container:** Dockerfile para empacotamento.
*   **Infraestrutura:** Terraform para provisionar EC2 (com Docker e AWS CLI instalados), S3, IAM Roles e Security Group liberando a porta 80.
*   **Automacao:** Workflow do GitHub Actions (deploy.yml) realiza o build, atualiza o ECR com as tags `SHA` e `latest`, remove containers antigos da porta 80 e sobe a nova versao na EC2 via SSH.

---

## Passo a Passo: Execucao Local

### Via Node.js
1. Instale as dependencias:
```bash
npm install
```
2. Execute a aplicacao:
```bash
npm start
```

### Via Docker
1. Faca o build da imagem:
```bash
docker build -t app-devops .
```
2. Execute o container:
```bash
docker run -p 3000:3000 app-devops
```
Acesse `http://localhost:3000`.

---

## Passo a Passo: Infraestrutura AWS

Utilize o Terraform para provisionar a base do projeto na sua conta AWS:

1. Inicialize o diretorio:
```bash
terraform init
```
2. Crie a infraestrutura (substitua pelo nome desejado para o bucket):
```bash
terraform apply -var="bucket_name=NOME_DO_SEU_BUCKET_UNICO"
```
Ao final da execucao, o terminal exibira o IP publico da instancia EC2 gerada.

---

## Passo a Passo: Deploy Automatico

O GitHub Actions cuida do deploy a cada novo push na branch `main`. Para configurar o ambiente, cadastre os seguintes **Secrets** no seu repositorio do GitHub:

*   `AWS_KEY`: Sua Access Key ID
*   `AWS_SECRET`: Sua Secret Access Key
*   `AWS_REGION`: Regiao AWS (exemplo: `us-east-1`)
*   `ECR_REPO`: URI do seu repositorio no ECR
*   `EC2_HOST`: IP publico da EC2 (obtido no output do Terraform)
*   `EC2_KEY`: Chave SSH (arquivo `.pem`) para acessar a EC2
