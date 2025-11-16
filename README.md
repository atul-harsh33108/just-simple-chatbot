# Simple Gemini Text Chatbot: DevOps Automation Project

[![Terraform](https://img.shields.io/badge/Terraform-v1.13.5-blue?logo=terraform)](https://terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-v2.10-green?logo=ansible)](https://ansible.com)
[![Streamlit](https://img.shields.io/badge/Streamlit-v1.51-orange?logo=streamlit)](https://streamlit.io)
[![AWS](https://img.shields.io/badge/AWS-Free%20Tier-yellow?logo=amazon-aws)](https://aws.amazon.com/free)
[![Python](https://img.shields.io/badge/Python-3.10-blue?logo=python)](https://python.org)

A **fully automated, reproducible DevOps pipeline** that deploys a **Streamlit-based text chatbot powered by Google Gemini AI** on **AWS EC2 (t2.micro, Free Tier)** using:
- **Terraform** → Infrastructure as Code (IaC)
- **Ansible** → Configuration Management
- **GitHub** → Source Control

The chatbot allows users to ask questions (e.g., "Explain Terraform"), view history, clear chat, and **download conversation logs**. All infrastructure and app deployment is **100% automated** and **idempotent**.

> **Live Demo**: http://43.205.129.100:8501 (if instance is running)  
> **Repo**: https://github.com/atul-harsh33108/just-simple-chatbot

---

## Features

| Feature | Description |
|-------|-----------|
| **AI Chat** | Powered by Google Gemini (`gemini-2.5-flash`) — fast, accurate responses |
| **Chat History** | Session-based, persists during browser session |
| **Clear History** | One-click reset via sidebar |
| **Export Chat** | Download full conversation as `.txt` with timestamps |
| **Secure Key** | API key prompted securely during Ansible run |
| **Idempotent** | Run Terraform/Ansible multiple times — no duplicates |
| **Free Tier Safe** | t2.micro, auto-teardown with `terraform destroy` |

---

## Architecture (Text Diagram)
[Local Machine]
│
├── Git Push → [GitHub Repo]
│
├── Terraform → [AWS Cloud]
│       │
│       └── VPC → Subnet → IGW → Route Table → Security Group → EC2 (Ubuntu)
│
└── Ansible → SSH into EC2 → Clone Repo → Install Deps → Run Streamlit as systemd service
│
└── http://<PUBLIC_IP>:8501 → Streamlit Chatbot (Public Access)
text---

## Project Structure
simple_chatbot_go/
├── app.py                  # Streamlit app
├── requirements.txt        # streamlit, google-generativeai, python-dotenv
├── .env                    # GEMINI_API_KEY=... (local only, .gitignore)
├── .gitignore
├── README.md
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── ansible/
├── hosts.ini
└── deploy.yml
text---

## Prerequisites (Before Starting)

| Tool | Version | Install Link |
|------|--------|-------------|
| Python | 3.10+ | [python.org](https://python.org) |
| Git | 2.30+ | [git-scm.com](https://git-scm.com) |
| Terraform | v1.13+ | [hashicorp.com/terraform](https://hashicorp.com/terraform) |
| AWS CLI | v2 | [aws.amazon.com/cli](https://aws.amazon.com/cli) |
| Ansible | 2.10+ | `sudo apt install ansible` (WSL) |
| WSL2 | Ubuntu 22.04 | Windows → Turn Windows features on → WSL |

---

## Step-by-Step Replication Guide

> **Total Time**: ~45–60 minutes  
> **Environment**: Windows 10/11 + WSL2 (Ubuntu)  
> **Cost**: $0 (AWS Free Tier)

---

### Step 1: Setup Local Environment (PowerShell)

```powershell
# 1. Create project directory
mkdir C:\Project\simple_chatbot_go
cd C:\Project\simple_chatbot_go

# 2. Create and activate virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# 3. Install dependencies
pip install streamlit google-generativeai python-dotenv

# 4. Freeze requirements (simplified)
echo streamlit> requirements.txt
echo google-generativeai>> requirements.txt
echo python-dotenv>> requirements.txt

# 5. Create .env file
notepad .env
# → Paste: GEMINI_API_KEY=your_actual_key_here
# → Save & Close
```

Step 2: Create app.py (Streamlit Chatbot)
```
python
# app.py
import streamlit as st
from datetime import datetime
from dotenv import load_dotenv
import os
import google.generativeai as genai

# Load environment variables
load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    st.error("GEMINI_API_KEY not found! Add to .env")
    st.stop()

genai.configure(api_key=api_key)
model = genai.GenerativeModel("gemini-2.5-flash")

# Initialize session state
if "messages" not in st.session_state:
    st.session_state.messages = []

st.title("Simple Gemini Text Chatbot")
st.caption("Ask anything — powered by Google Gemini")

# Sidebar controls
with st.sidebar:
    st.header("Controls")
    if st.button("Clear Chat History"):
        st.session_state.messages = []
        st.success("Chat cleared!")
    
    if st.button("Download Chat Log") and st.session_state.messages:
        log = "\n".join([
            f"[{m['timestamp']}] {m['role'].title()}: {m['content']}"
            for m in st.session_state.messages
        ])
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        st.download_button(
            "Download .txt",
            log,
            f"chat_history_{timestamp}.txt",
            "text/plain"
        )

# Display chat messages
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Chat input
if prompt := st.chat_input("Type your message..."):
    # Add user message
    st.session_state.messages.append({
        "role": "user",
        "content": prompt,
        "timestamp": datetime.now().strftime("%H:%M:%S")
    })
    with st.chat_message("user"):
        st.markdown(prompt)

    # Generate AI response
    with st.chat_message("assistant"):
        with st.spinner("Gemini is thinking..."):
            try:
                response = model.generate_content(prompt)
                reply = response.text
            except Exception as e:
                reply = f"Error: {str(e)}"
        st.markdown(reply)

    # Add assistant message
    st.session_state.messages.append({
        "role": "assistant",
        "content": reply,
        "timestamp": datetime.now().strftime("%H:%M:%S")
    })
```

Step 3: Git Setup (PowerShell)
```
powershell
# Initialize git
git init

# Create .gitignore
notepad .gitignore
Paste:
text
venv/
.env
__pycache__/
*.pyc
.terraform/
terraform.tfstate
terraform.tfstate.backup

powershell
git add .
git commit -m "Initial: Streamlit Gemini Chatbot"
git branch -M main
git remote add origin https://github.com/atul-harsh33108/just-simple-chatbot.git
git push -u origin main
```

Step 4: AWS Setup (Browser + WSL)

AWS Console:
Go to EC2 → Key Pairs → Create Key Pair  
Name: **AtulsAuthBasic**  
Download `.pem` → Save to `C:\Project\simple_chatbot_go\AtulsAuthBasic.pem`

WSL Terminal:

```
bash
# Copy key to WSL home
cp /mnt/c/Project/simple_chatbot_go/AtulsAuthBasic.pem ~/
chmod 400 ~/AtulsAuthBasic.pem

# Configure AWS CLI
aws configure
# → Access Key, Secret Key, region: ap-south-1, format: json
```

Step 5: Terraform — Provision EC2 (WSL)
```
bash
cd /mnt/c/Project/simple_chatbot_go
mkdir terraform && cd terraform
```

main.tf
```
hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "chatbot-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "chatbot-subnet" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "chatbot-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "chatbot-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "chatbot_sg" {
  name   = "chatbot-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "chatbot-sg" }
}

resource "aws_instance" "chatbot" {
  ami           = "ami-087d1c9a513324697"  # Ubuntu 22.04 LTS ap-south-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.chatbot_sg.id]
  key_name      = var.key_name

  tags = { Name = "chatbot-ec2" }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y python3-pip git
              EOF
}

output "ec2_public_ip" {
  value = aws_instance.chatbot.public_ip
}
```

variables.tf
```
hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "Name of EC2 Key Pair"
  type        = string
  default     = "AtulsAuthBasic"
}
```

terraform.tfvars
```
hcl
key_name = "AtulsAuthBasic"
```

```
bash
terraform init
terraform plan    # Should show 7 resources to add
terraform apply   # Type 'yes'
```

Output:
```
ec2_public_ip = "43.205.129.100"
```

→ Copy this!

Step 6: Ansible — Deploy App (WSL)
```
bash
cd /mnt/c/Project/simple_chatbot_go
mkdir ansible && cd ansible
```

hosts.ini
```
ini
[chatbot]
43.205.129.100 ansible_user=ubuntu ansible_ssh_private_key_file=~/AtulsAuthBasic.pem
```

deploy.yml → your provided version:
```
yaml
---
- name: Deploy Simple Gemini Chatbot to EC2
  hosts: chatbot
  become: yes
  vars_prompt:
    - name: gemini_api_key
      prompt: "Enter your Gemini API Key (from local .env): "
      private: no
  vars:
    repo_url: https://github.com/atul-harsh33108/just-simple-chatbot.git
    app_dir: /opt/chatbot
  tasks:
    - name: Update apt cache (idempotent)
      apt:
        update_cache: yes
      tags: update

    - name: Install prerequisites
      apt:
        name:
          - git
          - python3-pip
          - python3-venv
        state: present
      tags: install

    - name: Clone Git repo (if not exists)
      git:
        repo: "{{ repo_url }}"
        dest: "{{ app_dir }}"
        version: main
        force: no
      tags: deploy

    - name: Set ownership of app directory
      file:
        path: "{{ app_dir }}"
        owner: ubuntu
        group: ubuntu
        recurse: yes
      tags: deploy

    - name: Create virtual environment
      command: python3 -m venv "{{ app_dir }}/venv"
      args:
        creates: "{{ app_dir }}/venv/bin/activate"
      tags: venv

    - name: Upgrade pip, setuptools, and wheel
      command: "{{ app_dir }}/venv/bin/pip install --upgrade pip setuptools wheel"
      tags: install

    - name: Install Python requirements
      pip:
        requirements: "{{ app_dir }}/requirements.txt"
        virtualenv: "{{ app_dir }}/venv"
      notify: restart service
      tags: install

    - name: Create .env file with API key (owned by ubuntu)
      copy:
        content: "GEMINI_API_KEY={{ gemini_api_key }}\n"
        dest: "{{ app_dir }}/.env"
        owner: ubuntu
        group: ubuntu
        mode: '0600'
      notify: restart service
      tags: config

    - name: Create systemd service file
      copy:
        dest: /etc/systemd/system/chatbot.service
        content: |
          [Unit]
          Description=Simple Gemini Chatbot (Streamlit)
          After=network.target
          [Service]
          Type=simple
          User=ubuntu
          WorkingDirectory={{ app_dir }}
          Environment=PATH={{ app_dir }}/venv/bin
          ExecStart={{ app_dir }}/venv/bin/streamlit run {{ app_dir }}/app.py --server.port=8501 --server.address=0.0.0.0
          Restart=always
          RestartSec=10
          [Install]
          WantedBy=multi-user.target
      notify: restart service
      tags: service

    - name: Reload systemd daemon
      systemd:
        daemon_reload: yes
      tags: service

    - name: Enable and start chatbot service
      systemd:
        name: chatbot
        enabled: yes
        state: started
      tags: service

  handlers:
    - name: Restart chatbot service
      systemd:
        name: chatbot
        state: restarted
      listen: restart service
```

```
bash
# Test connectivity
ansible -i hosts.ini chatbot -m ping

# Deploy
ansible-playbook -i hosts.ini deploy.yml -v
```

Step 7: Test Live App
Open browser:

```
http://YOUR_EC2_IP:8501
```

Test:
- Type: **List some LLMs under 4B parameters**
- Response appears  
- Clear button works  
- Download saves `.txt`  

---

Step 8: Cleanup (Free Tier)
```
bash
cd ../terraform
terraform destroy  # Type 'yes'
```

---

Troubleshooting
```
IssueFix
Permission denied (publickey)chmod 400 ~/AtulsAuthBasic.pem
InvalidAMIID.NotFoundUse ami-087d1c9a513324697 (ap-south-1)
PermissionError: .envEnsure owner: ubuntu in Ansible .env task
Port 8501 blockedCheck SG inbound: TCP 8501 from 0.0.0.0/0
```

---

Future Enhancements

-  Add Nginx reverse proxy + HTTPS (Let’s Encrypt)
-  CI/CD with GitHub Actions
-  Monitoring with Prometheus + Grafana
-  Multi-region deployment
-  Blue/Green deployment with Terraform

---

Author  
**Atul Harsh**  
DevOps | Cloud | Automation  
GitHub: **atul-harsh33108**

---

Project Complete. Fully Reproducible. Zero Cost.
