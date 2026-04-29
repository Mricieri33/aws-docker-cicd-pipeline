# App Devops AWS CI/CD

Projeto de pipeline completo integrando Node.js, Docker, Terraform e GitHub Actions para deploy automatizado na AWS (EC2 + ECR).

## 🚀 Arquitetura e Componentes

- **Aplicação (`index.js`):** API em Node.js (Express) com endpoints `/health` e `/s3-check`.
- **Container (`Dockerfile`):** Empacota a aplicação expondo a porta 3000.
- **Infraestrutura (`main.tf`):** Código Terraform que provisiona uma instância EC2 (já com Docker instalado), Security Group liberando a porta 80, um bucket S3 e as IAM Roles necessárias.
- **CI/CD (`deploy.yml`):** Workflow do GitHub Actions que faz o build, envia a imagem para o ECR e realiza o deploy na EC2.

---

## 💻 Como Rodar Localmente

**Sem Docker:**
```bash
npm install
npm start
```

**Com Docker:**
```bash
docker build -t app-devops .
docker run -p 3000:3000 app-devops
```
A aplicação estará disponível em `http://localhost:3000`.

---

## ☁️ Como Subir a Infraestrutura (AWS)

Utilize o Terraform para provisionar os recursos necessários na sua conta AWS:

```bash
terraform init
terraform apply -var="bucket_name=NOME_DO_SEU_BUCKET_UNICO"
```
*O output retornará o IP público da sua EC2.*

---

## 🔄 Como Funciona o Deploy Automático

A pipeline de CI/CD é acionada a cada `push` na branch `main`. Para que ela funcione, você precisa configurar os seguintes **Secrets** nas configurações do seu repositório no GitHub:

- `AWS_KEY` (Sua Access Key da AWS)
- `AWS_SECRET` (Sua Secret Key da AWS)
- `AWS_REGION` (Ex: `us-east-1`)
- `ECR_REPO` (A URI do seu repositório criado no Amazon ECR)
- `EC2_HOST` (O IP Público da instância EC2 criada pelo Terraform)
- `EC2_KEY` (O conteúdo da chave `.pem` para acesso SSH à EC2)

### O que o workflow faz:
1. Conecta na AWS e faz login no Amazon ECR.
2. Faz o build da imagem Docker baseada no seu commit e envia (push) para o ECR.
3. Conecta via SSH na EC2 e roda a nova imagem na porta 80 (mapeando para a 3000 do container), substituindo a versão anterior automaticamente.
