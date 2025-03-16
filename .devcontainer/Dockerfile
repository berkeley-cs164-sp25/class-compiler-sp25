# Use the official Debian image as a base
FROM debian:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    gcc \
    nasm \
    make \
    gdb \
    build-essential \
    cmake \
    git \
    vim \
    && apt-get clean

# Create a non-root user (optional)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get install -y sudo \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set the user
USER $USERNAME

# Set the working directory
WORKDIR /workspace
