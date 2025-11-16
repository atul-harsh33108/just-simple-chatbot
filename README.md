# Simple Gemini Text Chatbot: DevOps Automation Project

[![Terraform](https://img.shields.io/badge/Terraform-v1.13.5-blue?logo=terraform)](https://terraform.io) [![Ansible](https://img.shields.io/badge/Ansible-v2.10-green?logo=ansible)](https://ansible.com) [![Streamlit](https://img.shields.io/badge/Streamlit-v1.51-orange?logo=streamlit)](https://streamlit.io) [![AWS](https://img.shields.io/badge/AWS-Free%20Tier-yellow?logo=amazon-aws)](https://aws.amazon.com/free)

A simple Streamlit-based text chatbot powered by Google Gemini AI, automated with Terraform (IaC for AWS EC2) and Ansible (config management). Processes queries (e.g., "What is DevOps?") with <2s responses. Includes chat history export. Built for DevOps syllabus: Reproducible deployment in <15 min.

![Demo Screenshot](https://via.placeholder.com/800x400?text=Streamlit+Chat+UI) <!-- Replace with actual screenshot URL from GitHub -->

## Features
- **Chat Interface**: Type queries → Gemini responds (gemini-2.5-flash model).
- **History Management**: Persistent session state; sidebar "Clear Chat History".
- **Export**: Download chat as timestamped .txt (e.g., "User: Query\n