# Simple Gemini Text Chatbot: DevOps Automation Project

[![Terraform](https://img.shields.io/badge/Terraform-v1.13.5-blue?logo=terraform)](https://terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-v2.10-green?logo=ansible)](https://ansible.com)
[![Streamlit](https://img.shields.io/badge/Streamlit-v1.51-orange?logo=streamlit)](https://streamlit.io)
[![AWS](https://img.shields.io/badge/AWS-Free%20Tier-yellow?logo=amazon-aws)](https://aws.amazon.com/free)
[![Python](https://img.shields.io/badge/Python-3.10-blue)](https://python.org)

> **A fully automated, reproducible deployment of a Streamlit-based AI chatbot using Google Gemini, provisioned with Terraform and configured via Ansible — 100% on AWS Free Tier.**

**Live Demo:** http://43.205.129.100:8501 *(EC2 public IP; may be destroyed)*

---

## ⭐ Features

| Feature | Description |
|--------|-------------|
| **AI-Powered Chat** | Real-time responses via Google Gemini (`gemini-2.5-flash`) |
| **Chat History** | Session-persistent conversation log |
| **Clear History** | One-click reset |
| **Export Chat Log** | Download as `.txt` with timestamp |
| **Idempotent Deployment** | Terraform + Ansible = reproducible in minutes |
| **Secure Config** | `.env` owned by `ubuntu`, mode `0600` |
| **Auto-Restart** | Managed with `systemd` |

---

## 🏗 Architecture (Text Diagram)

```
[Local Machine: Windows + WSL]
        │
        ├── GitHub Repo (main)
        │
        ▼
[Terraform] → AWS Cloud
        │
        ├── VPC (10.0.0.0/16)
        ├── Public Subnet (10.0.1.0/24)
        ├── Internet Gateway + Route Table
        ├── Security Group (22, 8501 open)
        └── EC2 t2.micro (Ubuntu 22.04)
        │
        ▼
[Ansible] → Configures EC2
        ├── Clone Git repo → /opt/chatbot
        ├── python3-venv + pip install
        ├── .env with GEMINI_API_KEY
        ├── systemd service
        └── streamlit run app.py --server.port=8501
```

---

## 🧰 Tech Stack

| Layer | Tool | Version |
|-------|------|---------|
| **IaC** | Terraform | `1.13.5` |
| **Config Management** | Ansible | `2.10.8` |
| **Cloud** | AWS EC2 | Ubuntu 22.04 |
| **App** | Streamlit | `1.51.0` |
| **AI Model** | Google Gemini | `gemini-2.5-flash` |
| **Python** | 3.10 (venv) |

---

# 📘 Extremely Detailed Step-by-Step Replication Guide

> **Time Required:** 45–60 minutes  
> **Cost:** $0 (AWS Free Tier)  
> **Environment:** Windows + WSL (Ubuntu)  
> **Directory:** `C:\Project\simple_chatbot_go`

---

# ✅ Step 1 — Install Prerequisites (10 min)

## 🟦 On Windows (PowerShell)

```powershell
# Python
winget install Python.Python.3

# Git
winget install Git.Git

# Terraform
winget install Hashicorp.Terraform

# AWS CLI
winget install Amazon.AWSCLI

# Verify
python --version
git --version
terraform version
aws --version
```

---

## 🟩 On WSL (Ubuntu)

```bash
wsl        # open WSL
sudo apt update && sudo apt upgrade -y
sudo apt install ansible git -y

# Verify
ansible --version
git --version
```

---

# ✅ Step 2 — AWS Setup (5 min)

## IAM User

1. Go to IAM Console  
2. Create user  
3. Attach **AmazonEC2FullAccess**  
4. Generate **Access Key + Secret Key**

---

## EC2 Key Pair

AWS Console → EC2 → Key Pairs → Create

Name: **AtulsAuthBasic**

Move to WSL:

```bash
cp /mnt/c/Downloads/AtulsAuthBasic.pem ~/
chmod 400 ~/AtulsAuthBasic.pem
```

---

## Configure AWS CLI

```bash
aws configure
# Enter:
# Access Key
# Secret Key
# Region: ap-south-1
# Output: json
```

---

# ✅ Step 3 — Local App Development (10 min)

## Create Project Folder

```powershell
mkdir simple_chatbot_go
cd simple_chatbot_go
```

---

## Create Python venv

```powershell
python -m venv venv
venv\Scripts\Activate.ps1
```

---

## Install Python Packages

```powershell
pip install streamlit google-generativeai python-dotenv
pip freeze > requirements.txt
```

---

## Simplified requirements.txt

```
streamlit
google-generativeai
python-dotenv
```

---

## Create `.env`

```
GEMINI_API_KEY=your_actual_gemini_key_here
```

---

## Create `app.py`

```python
import streamlit as st
from dotenv import load_dotenv
import google.generativeai as genai
import os
from datetime import datetime

load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    st.error("GEMINI_API_KEY not found! Check .env")
    st.stop()

genai.configure(api_key=api_key)
model = genai.GenerativeModel("gemini-2.5-flash")

st.title("Simple Gemini Text Chatbot")
st.caption("Ask anything — powered by Google Gemini")

if "history" not in st.session_state:
    st.session_state.history = []

for msg in st.session_state.history:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

if prompt := st.chat_input("Type your message..."):
    st.session_state.history.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        with st.spinner("Gemini is thinking..."):
            response = model.generate_content(prompt)
            reply = response.text
        st.markdown(reply)
    st.session_state.history.append({"role": "assistant", "content": reply})

with st.sidebar:
    st.header("Controls")
    if st.button("Clear Chat History"):
        st.session_state.history = []
        st.success("Chat cleared!")
        st.rerun()

    if st.session_state.history:
        log = "\n".join([
            f"{msg['role'].title()}: {msg['content']}"
            for msg in st.session_state.history
        ])
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        st.download_button(
            label="Download Chat Log",
            data=log,
            file_name=f"chat_history_{timestamp}.txt",
            mime="text/plain"
        )
```

---

## Test Locally

```powershell
streamlit run app.py
```

Open: http://localhost:8501  
Works? → Close terminal

---

# ✅ Step 4 — GitHub Setup (5 min)

## `.gitignore`

```
venv/
__pycache__/
*.pyc
.env
.terraform/
terraform.tfstate*
```

---

## Push to GitHub

```powershell
git init
git add .
git commit -m "Initial: Streamlit Gemini Chatbot"
git branch -M main
git remote add origin https://github.com/atul-harsh33108/just-simple-chatbot.git
git push -u origin main
```

---

# ✅ Step 5 — Terraform Provisioning (10 min)

Inside WSL:

```bash
cd /mnt/c/Project/simple_chatbot_go
mkdir terraform && cd terraform
```

Paste your **main.tf**, **variables.tf**, **terraform.tfvars**.

---

## Initialize & Apply

```bash
terraform init
terraform plan
terraform apply
```

Output:

```bash
terraform output ec2_public_ip
# Example → 43.205.129.100
```

---

# ✅ Step 6 — Ansible Deployment (10 min)

```bash
cd /mnt/c/Project/simple_chatbot_go
mkdir ansible && cd ansible
```

---

## `hosts.ini`

```
[chatbot]
43.205.129.100 ansible_user=ubuntu ansible_ssh_private_key_file=/home/atul/AtulsAuthBasic.pem
```

---

## Test SSH connectivity

```bash
ansible -i hosts.ini chatbot -m ping
# → pong
```

---

## Run Deployment

```bash
ansible-playbook -i hosts.ini deploy.yml -v
```

Enter Gemini API Key when prompted.

Final output:

```
ok=12 changed=7 failed=0
```

---

# ✅ Step 7 — Final Testing (5 min)

Open:

👉 **http://43.205.129.100:8501**

Test:

✔ Ask something  
✔ Download Chat Log  
✔ Clear Chat History  

---

# ✅ Step 8 — Teardown (Free Tier Safety)

```bash
cd ../terraform
terraform destroy
```

---

# 📁 Project Structure

```
simple_chatbot_go/
├── app.py
├── requirements.txt
├── .env
├── .gitignore
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── ansible/
    ├── hosts.ini
    └── deploy.yml
```

---

# 🚀 Future Enhancements

- Add Nginx reverse proxy + HTTPS (Let’s Encrypt)
- CI/CD Pipeline (GitHub Actions)
- Monitoring with Prometheus + Grafana
- Auto-scaling with Terraform `count`
- Switch to Docker + ECS + ALB
- Use SSM Parameter Store instead of .env

---

# 📚 References

- Terraform AWS Provider  
- Ansible Documentation  
- Streamlit Docs  
- Google Gemini API  

---

# ✨ Made with ❤️ for DevOps & Infrastructure Automation Course  
### Submitted by: **Atul Harsh**

