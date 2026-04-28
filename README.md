# AWS Docker CI/CD Pipeline

Aplicacao Node.js empacotada com Docker, publicada no Amazon ECR via GitHub Actions e implantada automaticamente em uma EC2.

## Fluxo

```text
Codigo
  ↓
GitHub
  ↓
GitHub Actions
  ↓
Docker Build
  ↓
Amazon ECR
  ↓
EC2
  ↓
Browser
```

## Componentes

- aplicacao Express em `index.js`
- imagem Docker definida em `Dockerfile`
- workflow de build, push e deploy em `.github/workflows/deploy.yml`
- infraestrutura base em `main.tf`

## Endpoints

- `/health` usado pelo `HEALTHCHECK` do Docker para validar se a aplicacao respondeu com `200 OK`
- `/s3-check`

## Pipeline

O workflow [`deploy.yml`](/home/mricieri33/App/.github/workflows/deploy.yml:1) faz:

1. checkout do codigo
2. configuracao das credenciais AWS
3. login no ECR
4. build da imagem Docker
5. tag com o `GITHUB_SHA`
6. push da imagem para o ECR com as tags `GITHUB_SHA` e `latest`
7. execucao remota na EC2 via AWS Systems Manager (SSM)
8. pull da nova imagem
9. remocao do container atual
10. subida do novo container
11. validacao do endpoint `/health`

### Secrets obrigatorios

- `AWS_KEY`
- `AWS_SECRET`
- `AWS_REGION`
- `ECR_REPO`

`EC2_INSTANCE_ID` deixa de ser obrigatorio se a instancia puder ser encontrada pela tag `Name`.

### Variables opcionais

- `IMAGE_NAME`
- `CONTAINER_NAME`
- `HOST_PORT`
- `CONTAINER_PORT`
- `EC2_TAG_NAME`

Se as variables nao forem definidas, o workflow usa:

- `IMAGE_NAME=devops-app`
- `CONTAINER_NAME=devops-app`
- `HOST_PORT=80`
- `CONTAINER_PORT=3000`
- `EC2_TAG_NAME=app-ec2`

## Deploy automatico na EC2

### Pre-requisitos

- EC2 com Docker e AWS CLI
- SSM Agent ativa na EC2
- IAM Role na EC2 com permissao de leitura no ECR e `AmazonSSMManagedInstanceCore`
- porta `80` liberada no Security Group

### Fluxo de troca do container

Quando houver push na branch `main` ou execucao manual do workflow:

```bash
aws ssm send-command --instance-ids <EC2_INSTANCE_ID> ...
docker pull <ECR_REPO>:<GITHUB_SHA>
docker rm -f <CONTAINER_NAME> || true
docker run -d --name <CONTAINER_NAME> --restart unless-stopped -p <HOST_PORT>:<CONTAINER_PORT> <ECR_REPO>:<GITHUB_SHA>
curl http://127.0.0.1:<HOST_PORT>/health
```

Se `EC2_INSTANCE_ID` nao estiver definido, a Action procura uma unica instancia em estado `running` com `tag:Name=<EC2_TAG_NAME>`. Se nenhuma ou mais de uma instancia for encontrada, o job falha antes do `send-command` com erro explicito.

O deploy remove o container atual e sobe o novo automaticamente pela Action.

## Execucao local

```bash
npm install
npm start
```

Ou com Docker:

```bash
docker build -t devops-app .
docker run -p 3000:3000 devops-app
```

## Infraestrutura

O [`main.tf`](/home/mricieri33/App/main.tf:1) prepara:

- EC2
- Security Group com `80`
- IAM Role/Profile para leitura no ECR e gerenciamento por SSM
- bucket S3 parametrizado
- instalacao de Docker e AWS CLI via `user_data`
- inicializacao do `amazon-ssm-agent`

## Observacoes

- a aplicacao escuta na porta interna `3000`
- o container publica `80:3000` na EC2
- o `HEALTHCHECK` usa `/health`
- o deploy na EC2 e automatico via GitHub Actions
- a Action nao depende de SSH aberto na internet
