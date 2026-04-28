# AWS Docker CI/CD Pipeline

Aplicacao Node.js empacotada com Docker, publicada no Amazon ECR via GitHub Actions e executada manualmente em uma EC2.

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
- workflow de build e push em `.github/workflows/deploy.yml`
- infraestrutura base em `main.tf`

## Endpoints

- `/health`
- `/s3-check`

## Pipeline

O workflow [`deploy.yml`](/home/mricieri33/App/.github/workflows/deploy.yml:1) faz apenas:

1. checkout do codigo
2. configuracao das credenciais AWS
3. login no ECR
4. build da imagem Docker
5. tag com o `GITHUB_SHA`
6. push da imagem para o ECR

### Secrets obrigatorios

- `AWS_KEY`
- `AWS_SECRET`
- `AWS_REGION`
- `ECR_REPO`

### Variable opcional

- `IMAGE_NAME`

Se `IMAGE_NAME` nao for definida, o workflow usa `devops-app`.

## Deploy manual na EC2

### Pre-requisitos

- EC2 com Docker instalado
- AWS CLI instalada na EC2
- IAM Role na EC2 com permissao de leitura no ECR
- porta `80` liberada no Security Group
- porta `22` liberada para o seu IP

### 1. Conectar na instancia

```bash
ssh -i <SUA_CHAVE.pem> ec2-user@<EC2_PUBLIC_IP>
```

### 2. Fazer login no ECR

```bash
aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <ECR_REGISTRY>
```

Exemplo de `ECR_REGISTRY`:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### 3. Baixar a imagem

```bash
docker pull <ECR_REPO>:<IMAGE_TAG>
```

`IMAGE_TAG` normalmente sera o SHA do commit publicado pelo workflow.

### 4. Subir ou atualizar o container

```bash
docker rm -f devops-app || true
docker run -d --name devops-app -p 80:3000 <ECR_REPO>:<IMAGE_TAG>
```

### 5. Validar

Na propria EC2:

```bash
curl http://localhost/health
```

De fora da instancia:

```bash
curl http://<EC2_PUBLIC_IP>/health
```

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
- Security Group com `22` e `80`
- IAM Role/Profile para leitura no ECR
- bucket S3 parametrizado

## Observacoes

- a aplicacao escuta na porta interna `3000`
- o container publica `80:3000` na EC2
- o `HEALTHCHECK` usa `/health`
- o deploy na EC2 e manual
