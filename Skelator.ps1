# Create-AI-Project.ps1
# This script scaffolds a new project directory with a modern, AI-focused tech stack.

# 1. Defines the parameters the script accepts.
#    -ProjectName is a mandatory string input.
param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

# --- Configuration ---
$DefaultDbUser = "postgres"
$DefaultDbPass = "password"
$DbName = $ProjectName.ToLower()
# --- End Configuration ---

Write-Host "--> Creating new AI project: $ProjectName"

# 2. Create Directory Structure
New-Item -ItemType Directory -Path $ProjectName -Force | Out-Null
Set-Location -Path $ProjectName

Write-Host "    - Creating folder structure..."
New-Item -ItemType Directory -Path ".github/workflows" -Force | Out-Null
New-Item -ItemType Directory -Path "backend/app/api/v1", "backend/app/core", "backend/app/models", "backend/prisma", "backend/scripts" -Force | Out-Null
New-Item -ItemType Directory -Path "frontend/app/api/client", "frontend/components/ui", "frontend/lib", "frontend/styles" -Force | Out-Null

# 3. Create and Populate Files
Write-Host "--> Creating root configuration files..."

# .gitignore
$gitignoreContent = @"
# Local Environment
.env.local
.DS_Store

# Python
venv/
*.pyc
__pycache__/

# Node.js
node_modules/
.next/
npm-debug.log
package-lock.json

# IDE
.idea/
.vscode/
"@
Set-Content -Path ".gitignore" -Value $gitignoreContent

# .env.example
$envExampleContent = @"
# PostgreSQL Configuration
DATABASE_URL="postgresql://${DefaultDbUser}:${DefaultDbPass}@localhost:5432/${DbName}"
POSTGRES_USER=${DefaultDbUser}
POSTGRES_PASSWORD=${DefaultDbPass}
POSTGRES_DB=${DbName}

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379

# Qdrant Configuration
QDRANT_HOST=localhost
QDRANT_PORT=6333

# OpenAI/AI Service Keys
OPENAI_API_KEY="sk-..."

# Auth.js Configuration
AUTH_SECRET="a_very_secret_string_for_jwt_hashing"
AUTH_URL="http://localhost:3000/api/auth"

# Application Settings
ENVIRONMENT=development
"@
Set-Content -Path ".env.example" -Value $envExampleContent

# docker-compose.yml
$dockerComposeContent = @"
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    env_file:
      - .env.local
    depends_on:
      - db
      - redis
      - qdrant

  db:
    image: ankane/pgvector
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: `$${POSTGRES_USER}
      POSTGRES_PASSWORD: `$${POSTGRES_PASSWORD}
      POSTGRES_DB: `$${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    ports:
      - "6379:6379"

  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
    volumes:
      - qdrant_storage:/qdrant/storage

volumes:
  postgres_data:
  qdrant_storage:
"@
Set-Content -Path "docker-compose.yml" -Value $dockerComposeContent

# README.md
Set-Content -Path "README.md" -Value "# $ProjectName`n`nProject overview and setup instructions."

Write-Host "--> Creating documentation templates for AI context..."

# BRD.md, PRD.md, MEMORY.md, TASK.md
Set-Content -Path "BRD.md" -Value "# Business Requirements: $ProjectName`n## 1. Vision and Goal`n* Problem: What problem are we solving?`n* Vision: What is the high-level vision for this product?`n* Success Metrics: How do we measure success?"
Set-Content -Path "PRD.md" -Value "# Product Requirements: $ProjectName`n## Feature 1: [Name of First Feature, e.g., User Authentication]`n* User Story: As a [user type], I want to [action] so that [benefit].`n* Acceptance Criteria:`n    * [ ] Criterion 1`n    * [ ] Criterion 2"
Set-Content -Path "MEMORY.md" -Value "# Project Memory and Decisions Log: $ProjectName`n## Architectural Decisions`n* $(Get-Date -Format 'yyyy-MM-dd'): Initial project setup using the 2025 Full Stack recommendation (FastAPI, Next.js, Prisma, pgvector)."
Set-Content -Path "TASK.md" -Value "# Current Development Task`n## Objective`nSet up the initial database schema and create the first API endpoint."

Write-Host "--> Creating backend structure..."

# backend/requirements.txt
Set-Content -Path "backend/requirements.txt" -Value "fastapi`nuvicorn[standard]`nprisma`nlangchain`nqdrant-client`nopenai`npsycopg2-binary`npgvector`npython-dotenv`npydantic`nredis"

# backend/Dockerfile
Set-Content -Path "backend/Dockerfile" -Value "FROM python:3.11-slim`nWORKDIR /app`nCOPY requirements.txt .`nRUN pip install --no-cache-dir -r requirements.txt`nCOPY . .`nCMD [`"uvicorn`", `"app.main:app`", `"--host`", `"0.0.0.0`", `"--port`", `"8000`"]"

# backend/prisma/schema.prisma
Set-Content -Path "backend/prisma/schema.prisma" -Value "generator client {`n  provider = `"prisma-client-py`"`n}`n`ndatasource db {`n  provider = `"postgresql`"`n  url      = env(`"DATABASE_URL`")`n}`n`nmodel User {`n  id        String   @id @default(uuid())`n  email     String   @unique`n  name      String?`n  createdAt DateTime @default(now()) @map(`"created_at`")`n  updatedAt DateTime @updatedAt @map(`"updated_at`")`n}"

# backend/app/main.py
Set-Content -Path "backend/app/main.py" -Value "from fastapi import FastAPI`nfrom .api.v1.router import router as v1_router`n`napp = FastAPI(title=`"$ProjectName`")`n`n@app.get(`/api/health`, tags=[`'Health`'])`ndef health_check():`n    return {`"status`": `"ok`"}`n`napp.include_router(v1_router, prefix=`"/api/v1`")"

# backend/app/api/v1/router.py
Set-Content -Path "backend/app/api/v1/router.py" -Value "from fastapi import APIRouter`n`nrouter = APIRouter()`n`n@router.get(`/hello`)`ndef say_hello():`n    return {`"message`": `"Hello from API v1`"}"

# backend/app/agents.py
Set-Content -Path "backend/app/agents.py" -Value "# This file is for your LangChain agents.`n# You can define agent tools, prompts, and chains here."

# Create empty __init__.py files
New-Item -Path "backend/app/__init__.py", "backend/app/api/__init__.py", "backend/app/core/__init__.py", "backend/app/models/__init__.py" -ItemType File | Out-Null

Write-Host "--> Creating frontend structure..."

# frontend/package.json
$packageJsonContent = @"
{
  "name": "$($ProjectName.ToLower())-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "@radix-ui/react-slot": "latest",
    "@tanstack/react-query": "latest",
    "class-variance-authority": "latest",
    "clsx": "latest",
    "lucide-react": "latest",
    "next": "14.2.3",
    "react": "^18",
    "react-dom": "^18",
    "tailwind-merge": "latest",
    "tailwindcss-animate": "latest",
    "zustand": "latest"
  },
  "devDependencies": {
    "typescript": "^5",
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "postcss": "^8",
    "tailwindcss": "^3.4.1",
    "eslint": "^8",
    "eslint-config-next": "14.2.3"
  }
}
"@
Set-Content -Path "frontend/package.json" -Value $packageJsonContent

# frontend/tailwind.config.ts
Set-Content -Path "frontend/tailwind.config.ts" -Value "import type { Config } from `"tailwindcss`"`n`nconst config = {`n  darkMode: [`"class`"],`n  content: [`n    `'./pages/**/*.{ts,tsx}`',`n    `'./components/**/*.{ts,tsx}`',`n    `'./app/**/*.{ts,tsx}`',`n    `'./src/**/*.{ts,tsx}`',`n	],`n  prefix: `"`",`n  theme: {`n    container: {`n      center: true,`n      padding: `"2rem`",`n      screens: {`n        `"2xl`": `"1400px`",`n      },`n    },`n    extend: {`n      keyframes: {`n        `"accordion-down`": {`n          from: { height: `"0`" },`n          to: { height: `"var(--radix-accordion-content-height)`" },`n        },`n        `"accordion-up`": {`n          from: { height: `"var(--radix-accordion-content-height)`" },`n          to: { height: `"0`" },`n        },`n      },`n      animation: {`n        `"accordion-down`": `"accordion-down 0.2s ease-out`",`n        `"accordion-up`": `"accordion-up 0.2s ease-out`",`n      },`n    },`n  },`n  plugins: [require(`"tailwindcss-animate`")],`n} satisfies Config`n`nexport default config"

# frontend/styles/globals.css
Set-Content -Path "frontend/styles/globals.css" -Value "@tailwind base;`n@tailwind components;`n@tailwind utilities;`n`n@layer base {`n  :root {`n    --background: 0 0% 100%;`n    --foreground: 222.2 84% 4.9%;`n    --card: 0 0% 100%;`n    --card-foreground: 222.2 84% 4.9%;`n    --popover: 0 0% 100%;`n    --popover-foreground: 222.2 84% 4.9%;`n    --primary: 222.2 47.4% 11.2%;`n    --primary-foreground: 210 40% 98%;`n    --secondary: 210 40% 96.1%;`n    --secondary-foreground: 222.2 47.4% 11.2%;`n    --muted: 210 40% 96.1%;`n    --muted-foreground: 215.4 16.3% 46.9%;`n    --accent: 210 40% 96.1%;`n    --accent-foreground: 222.2 47.4% 11.2%;`n    --destructive: 0 84.2% 60.2%;`n    --destructive-foreground: 210 40% 98%;`n    --border: 214.3 31.8% 91.4%;`n    --input: 214.3 31.8% 91.4%;`n    --ring: 222.2 84% 4.9%;`n    --radius: 0.5rem;`n  }`n`n  .dark {`n    --background: 222.2 84% 4.9%;`n    --foreground: 210 40% 98%;`n    --card: 222.2 84% 4.9%;`n    --card-foreground: 210 40% 98%;`n    --popover: 222.2 84% 4.9%;`n    --popover-foreground: 210 40% 98%;`n    --primary: 210 40% 98%;`n    --primary-foreground: 222.2 47.4% 11.2%;`n    --secondary: 217.2 32.6% 17.5%;`n    --secondary-foreground: 210 40% 98%;`n    --muted: 217.2 32.6% 17.5%;`n    --muted-foreground: 215 20.2% 65.1%;`n    --accent: 217.2 32.6% 17.5%;`n    --accent-foreground: 210 40% 98%;`n    --destructive: 0 62.8% 30.6%;`n    --destructive-foreground: 210 40% 98%;`n    --border: 217.2 32.6% 17.5%;`n    --input: 217.2 32.6% 17.5%;`n    --ring: 212.7 26.8% 83.9%;`n  }`n}`n`n@layer base {`n  * {`n    @apply border-border;`n  }`n  body {`n    @apply bg-background text-foreground;`n  }`n}"

# frontend/app/layout.tsx
Set-Content -Path "frontend/app/layout.tsx" -Value "import type { Metadata } from `"next`";`nimport { Inter } from `"next/font/google`";`nimport `"../styles/globals.css`";`n`nconst inter = Inter({ subsets: [`"latin`"] });`n`nexport const metadata: Metadata = {`n  title: `"$ProjectName`",`n  description: `"Generated by the Skelator script`",`n};`n`nexport default function RootLayout({`n  children,`n}: Readonly<{`n  children: React.ReactNode;`n}>) {`n  return (`n    <html lang=`"en`">`n      <body className={inter.class`Name`}>{children}</body>`n    </html>`n  );`n}"

# frontend/app/page.tsx
Set-Content -Path "frontend/app/page.tsx" -Value "export default function Home() {`n  return (`n    <main className=`"flex min-h-screen flex-col items-center justify-center p-24`">`n      <h1 className=`"text-4xl font-bold`">$ProjectName</h1>`n    </main>`n  );`n}"

Write-Host "--> Creating DevOps placeholders..."

# .github/workflows/ci-cd.yml
$ciCdContent = @"
name: CI Pipeline

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  test-backend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Run tests (placeholder)
        run: echo "No backend tests configured yet"

  test-frontend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend
    steps:
      - uses: actions/checkout@v4
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: npm ci
      - name: Run lint and build
        run: |
          npm run lint
          npm run build
"@
Set-Content -Path ".github/workflows/ci-cd.yml" -Value $ciCdContent

# terraform.tf
Set-Content -Path "terraform.tf" -Value "# Terraform configuration placeholder`n`n# provider `"aws`" {`n#   region = `"us-east-1`"`n# }`n`n# resource `"aws_db_instance`" `"default`" {`n#   allocated_storage    = 10`n#   engine               = `"postgres`"`n#   engine_version       = `"14`"`n#   instance_class       = `"db.t3.micro`"`n#   db_name              = `"$DbName`"`n#   username             = `"$DefaultDbUser`"`n#   password             = `"<SET_IN_TF_VARS>`"`n#   skip_final_snapshot  = true`n# }"

# Create other empty files
New-Item -Path "frontend/next.config.mjs" -ItemType File | Out-Null

# 4. Final Instructions
Write-Host ""
Write-Host "Success! Project '$ProjectName' is ready." -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:"
Write-Host "1. cd $ProjectName"
Write-Host "2. Create your secret file: Copy-Item .env.example .env.local"
Write-Host "3. Edit .env.local with your actual secrets."
Write-Host "4. Review and update the .md files with your project specifics."
Write-Host "5. Run 'docker-compose up -d' to start your databases."
