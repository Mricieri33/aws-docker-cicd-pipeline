# AWS Docker CI/CD Pipeline

Aplicacao Node.js com deploy automatizado na AWS usando Docker, Amazon ECR, EC2 e GitHub Actions.

## Visao geral

O projeto faz:

- build da imagem Docker a partir da aplicacao Express
- push da imagem para o Amazon ECR
- deploy remoto em uma instancia EC2 via SSH
- validacao da nova versao com healthcheck antes da troca do container principal
- rollback basico se a promocao da nova versao falhar

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
  ├─ container candidato
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
6. Na EC2, sobe um container candidato em porta separada.
7. Executa validacao de saude no candidato.
8. Se estiver saudavel, promove a nova imagem para o container principal.
9. Se a promocao falhar, tenta restaurar a imagem anterior.

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
- `CANDIDATE_PORT`
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
- O deploy atual reduz risco de downtime comparado ao fluxo que removia o container antigo antes de validar o novo.
- O arquivo `terraform.tfstate` existe no projeto, mas normalmente nao deveria ser versionado em repositorio compartilhado.

## Objetivo

Demonstrar pratica com:

- containerizacao
- pipeline CI/CD
- integracao com AWS
- deploy automatizado com validacao basica de saude
