Extremely Well-Defined Steps to Replicate This Project
These steps recreate the entire setup from scratch on a fresh machine (Windows + WSL Ubuntu; assumes AWS account/free tier). Time: ~45-60 min. Use PowerShell for local dev/Git, WSL for Terraform/Ansible/AWS. Dir: C:\Project\simple_chatbot_go (mounted as /mnt/c/Project/simple_chatbot_go in WSL).
Prerequisites (5 min)

Install Tools (Windows):
Python 3.12+: Download from python.org; verify: python --version.
Git: From git-scm.com; verify: git --version.
Terraform: From hashicorp.com/terraform/install; verify: terraform version (v1.12+).
AWS CLI: From aws.amazon.com/cli; verify: aws --version.

Install Tools (WSL: Open Ubuntu terminal via wsl):
Update: sudo apt update && sudo apt upgrade -y.
Ansible: sudo apt install ansible -y; verify: ansible --version (2.10+).
Terraform/AWS CLI: Already in your setup; verify as above.
Git: sudo apt install git -y; verify: git --version.

AWS Setup (Console: console.aws.amazon.com):
IAM User: Create with "AmazonEC2FullAccess" policy; generate Access Key/Secret.
EC2 Key Pair: Create "AtulsAuthBasic" (download .pem; chmod 400 in WSL: cp /mnt/c/Downloads/AtulsAuthBasic.pem ~/ && chmod 400 ~/AtulsAuthBasic.pem).
Configure CLI (WSL): aws configure (enter keys, region=ap-south-1, output=json). Verify: aws sts get-caller-identity.

Gemini API Key: Get from aistudio.google.com/app/apikey (free tier: 15 RPM). Note it for .env.

Step 1: Local App Development (10 min, PowerShell in C:\Project)

mkdir simple_chatbot_go && cd simple_chatbot_go.
Create/activate venv: python -m venv venv && venv\Scripts\Activate.ps1.
Install deps: pip install streamlit google-generativeai python-dotenv.
Generate requirements: pip freeze > requirements.txt (edit to essentials: streamlit, google-generativeai, python-dotenv).
Create .env: notepad .env → GEMINI_API_KEY=your_key_here.
Create app.py (paste code from earlier: Streamlit chat with Gemini, export feature).
Test: streamlit run app.py → http://localhost:8501; query "Hello" → Response. Ctrl+C to stop.

Step 2: Git Setup (5 min, PowerShell)

git init && notepad .gitignore (paste: venv/, .env, *.pyc, pycache/, .terraform/, terraform.tfstate).
git add . && git commit -m "Initial: Streamlit Gemini Chatbot".
Remote: git remote add origin https://github.com/atul-harsh33108/just-simple-chatbot.git && git branch -M main && git push -u origin main.
Auth: Use GitHub PAT if 2FA (settings/tokens, repo scope).

Verify: GitHub repo shows app.py, requirements.txt, .gitignore.

Step 3: Terraform Provisioning (10 min, WSL)

cd /mnt/c/Project/simple_chatbot_go && mkdir terraform && cd terraform.
nano main.tf (paste VPC/subnet/IGW/route/SG/EC2 code; AMI="ami-087d1c9a513324697" for ap-south-1; key_name="AtulsAuthBasic").
nano variables.tf (aws_region="ap-south-1", key_name="AtulsAuthBasic").
nano terraform.tfvars (key_name = "AtulsAuthBasic").
terraform init && terraform plan (Plan: 7 adds).
terraform apply (yes; ~3 min). Copy output: ec2_public_ip="43.205.129.100".
Verify: terraform output ec2_public_ip && aws ec2 describe-instances --filters "Name=tag:Name,Values=chatbot-ec2".

Step 4: Ansible Deployment (10 min, WSL)

cd /mnt/c/Project/simple_chatbot_go && mkdir ansible && cd ansible.
nano hosts.ini ([chatbot]\nIP ansible_user=ubuntu ansible_ssh_private_key_file=~/AtulsAuthBasic.pem).
ansible -i hosts.ini chatbot -m ping ("pong").
nano deploy.yml (paste your updated YAML above).
ansible-playbook -i hosts.ini deploy.yml -v (enter key; ~5 min, changed=7+).
Verify: ansible -i hosts.ini chatbot -m shell -a "sudo systemctl status chatbot" -b (active running). Logs: ansible -i hosts.ini chatbot -m shell -a "sudo journalctl -u chatbot -n 10" -b.

Step 5: Testing & Teardown (5 min)

Browser: http://IP:8501 → Chat "What is IaC?" → Response. Export history.
Scale (opt): Terraform count=2, apply, update hosts.ini, re-playbook.
Teardown: cd ../terraform && terraform destroy (yes).

Troubleshoot: SSH fail? Chmod 400 key. AMI error? Query AWS for Ubuntu 22.04 ID. Deps fail? Simplified requirements.txt.

