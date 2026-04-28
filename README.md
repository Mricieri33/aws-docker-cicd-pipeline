# AWS Docker CI/CD Pipeline

Aplicacao Node.js com deploy automatizado na AWS usando Docker, Amazon ECR, EC2 e GitHub Actions.

## Visao geral

O projeto faz:

- build da imagem Docker a partir da aplicacao Express
- push da imagem para o Amazon ECR
- deploy remoto em uma instancia EC2 via SSH
- execucao simples do container na EC2 com `docker pull` e `docker run`

## Arquitetura

```text
GitHub
  ↓
GitHub Actions
  ↓
Docker Build
  ↓
Amazon ECR
  ↓
EC2
  └─ container principal
  ↓
Browser
```

## Stack

- Node.js
- Express
- Docker
- GitHub Actions
- AWS ECR
- AWS EC2
- Terraform

## Estrutura

```text
.
├── index.js
├── package.json
├── Dockerfile
├── main.tf
├── public/
├── .github/
│   └── workflows/
│       └── deploy.yml
└── README.md
```

## Endpoints

- `/health`: endpoint simples para verificacao de saude da aplicacao
- `/s3-check`: consulta buckets S3 usando as credenciais configuradas no ambiente

## Como funciona o deploy

A pipeline em `deploy.yml` roda em `push` para `main` ou manualmente via `workflow_dispatch`.

Fluxo atual:

1. Faz checkout do codigo.
2. Configura credenciais AWS.
3. Faz login no ECR.
4. Gera a tag da imagem com o `GITHUB_SHA`.
5. Builda e publica a imagem.
6. Na EC2, faz `docker pull` da nova imagem.
7. Remove o container antigo.
8. Sobe o novo container na porta configurada.

## Execucao local

Instalacao:

```bash
npm install
```

Aplicacao:

```bash
node index.js
```

Container:

```bash
docker build -t devops-app .
docker run -p 3000:3000 devops-app
```

Teste de saude:

```bash
curl http://localhost:3000/health
```

## Configuracao do GitHub Actions

### Secrets obrigatorios

- `AWS_KEY`
- `AWS_SECRET`
- `AWS_REGION`
- `ECR_REPO`
- `EC2_HOST`
- `EC2_KEY`

### Variables recomendadas

- `IMAGE_NAME`
- `CONTAINER_NAME`
- `PORT`
- `EC2_USER`

Se essas variables nao forem definidas, o workflow usa fallback no proprio YAML.

## Infraestrutura e rede

Para a EC2, o Security Group deve permitir pelo menos:

- porta `22` para SSH
- porta `80` para acesso HTTP, ou a porta publicada em `PORT`
- porta interna `3000` usada pela aplicacao dentro do container

## Observacoes

- A aplicacao escuta internamente na porta `3000`.
- O `Dockerfile` possui `HEALTHCHECK` nativo usando `/health`.
- O deploy atual e simples: atualiza a imagem no ECR e recria o container na EC2.
- O arquivo `terraform.tfstate` existe no projeto, mas normalmente nao deveria ser versionado em repositorio compartilhado.

## Objetivo

Demonstrar pratica com:

- containerizacao
- pipeline CI/CD
- integracao com AWS
- deploy automatizado com Docker, ECR e EC2
