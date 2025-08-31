# Start from the official n8n Docker image
FROM n8nio/n8n:latest

# Switch to the root user to install software
USER root

# Download and install Typst
# We use the 'musl' version because the n8n base image (Alpine Linux) uses musl libc.
RUN wget https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.gz && \
    tar -xzf typst-x86_64-unknown-linux-musl.tar.gz && \
    mv typst-x86_64-unknown-linux-musl/typst /usr/local/bin/ && \
    chmod +x /usr/local/bin/typst && \
    rm -rf typst-x86_64-unknown-linux-musl*

# Switch back to the non-priveleged node user
USER node:wq
