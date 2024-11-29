# syntax=docker/dockerfile:1

# Start from TensorFlow 1.4.0 GPU-enabled w/ Python 3 image.
FROM tensorflow/tensorflow:1.14.0-gpu-py3

ARG USERNAME=developer

# >Be root
USER root

# Set root psw for easy sudoing.
RUN echo "root:psw" | chpasswd

# Install basic utilities.
RUN apt-get update ; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        sudo \
        ssh \
        git \
        build-essential \
        less \
        htop \
        tmux \
        zip \
        unzip \
        vim \
        wget

# Copy the .env file to the container.
COPY .env /tmp/.env

# Use copied .env file to load user information + create user + group.
RUN set -u && \
    . /tmp/.env && \
    rm /tmp/.env && \
    # Remove any existing user(s) with the same name and/or UID.
    getent passwd $USERNAME && userdel -r $USERNAME || true && \
    getent passwd $USER_UID && userdel -r $(id -nu $USER_UID) || true && \
    # Create the group only if it doesn't already exist.
    getent group $GROUPNAME || getent group $GROUP_GID || groupadd --gid $GROUP_GID $GROUPNAME && \
    # Create user that matches host user + add it to the host group.
    useradd --uid $USER_UID --gid $GROUP_GID -m $USERNAME && \
    echo "$USERNAME:$USERNAME" | chpasswd && \
    # Add user to sudoers.
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Set container user + working directory to their home.
USER $USERNAME
WORKDIR /home/$USERNAME

# Set default environment variables.
ENV PYTHONUNBUFFERED=1
ENV PATH="$PATH:/home/$USERNAME:/home/$USERNAME/.local/bin"
