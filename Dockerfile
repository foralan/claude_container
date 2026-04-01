FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV UV_PROJECT_ENVIRONMENT=.linux_venv

# Install base dependencies and common dev tools
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    lsb-release \
    make \
    nano \
    ripgrep \
    sudo \
    unzip \
    vim \
    wget \
    zip \
    locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 LTS via NodeSource (current official method)
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Codex CLI globally
RUN npm install -g @openai/codex

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
       https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Bake global agent instructions into the image
COPY container-instructions.md /CLAUDE.md

# Create a non-root user with sudo access
ARG USER_UID=1000
RUN useradd -m -s /bin/bash -u ${USER_UID} agent \
    && usermod -aG sudo agent \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/agent \
    && chown agent:agent /CLAUDE.md

USER agent
WORKDIR /home/agent

# Install Claude Code via official shell script
ENV PATH="/home/agent/.local/bin:$PATH"
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Symlink AGENTS.md -> /CLAUDE.md so Codex reads the same instructions (CODEX_HOME defaults to ~)
RUN ln -s /CLAUDE.md /home/agent/AGENTS.md

CMD ["bash"]
