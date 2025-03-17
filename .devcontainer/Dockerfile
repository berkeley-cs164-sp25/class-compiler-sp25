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
      opam \
      dune \
      utop \
    && apt-get clean

# Create a non-root user (optional)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash && \
    apt-get install -y sudo && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to non-root user
USER $USERNAME

# Set the working directory
WORKDIR /workspace

# Initialize opam (using default settings)
RUN opam init --disable-sandboxing -y && eval $(opam env)

# Pin the local project and install all dune dependencies from the opam file.
# The '.' tells opam to use the current directory, which should contain your dune-project file.
RUN opam pin add -y . && opam install . --deps-only --with-test --with-doc

# Install Dev Dependencies 
RUN opam switch import switch-state.export
