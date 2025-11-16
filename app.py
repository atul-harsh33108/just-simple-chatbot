import streamlit as st
import google.generativeai as genai
from dotenv import load_dotenv
import os
from datetime import datetime

# Load environment variables
load_dotenv()

# Get API key
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    st.error("GEMINI_API_KEY not found! Add it to .env file.")
    st.stop()

# Configure Gemini
try:
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-2.5-flash")  
except Exception as e:
    st.error(f"Failed to configure Gemini: {e}")
    st.stop()

# App title
st.title("Simple Gemini Text Chatbot")
st.caption("Ask anything — powered by Google Gemini")

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat messages
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Chat input
if prompt := st.chat_input("Type your message..."):
    # Add user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Generate AI response
    with st.chat_message("assistant"):
        with st.spinner("Gemini is thinking..."):
            try:
                response = model.generate_content(prompt)
                response_text = response.text
                st.markdown(response_text)
                st.session_state.messages.append({"role": "assistant", "content": response_text})
            except Exception as e:
                st.error(f"Gemini error: {str(e)}")

# Sidebar: Controls + Export History
with st.sidebar:
    st.header("Controls")
    if st.button("Clear Chat History"):
        st.session_state.messages = []
        st.success("Chat cleared!")
        st.rerun()
    
    # New feature: Export chat history as downloadable text file
    if st.session_state.messages:
        st.header("Save History")
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        chat_log = "\n".join([f"{msg['role'].title()}: {msg['content']}" for msg in st.session_state.messages])
        filename = f"chat_history_{timestamp}.txt"
        st.download_button(
            label="Download Chat Log",
            data=chat_log,
            file_name=filename,
            mime="text/plain"
        )
    else:
        st.info("Start chatting to export history!")