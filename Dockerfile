# Use the official Ubuntu 20.04 as a base image
FROM ubuntu:20.04

# Disable prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    software-properties-common \
    apt-transport-https \
    ca-certificates

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && apt-get install -y terraform

# Install Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && apt-get install -y azure-cli

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENV ARM_CLIENT_ID=${ARM_CLIENT_ID}
ENV ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET}
ENV ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION} 
ENV ARM_TENANT_ID=${ARM_TENANT}

# Default command to run in the container
CMD ["bash"]
