# Python version: 3.8
ARG PYTORCH="1.11.0"
ARG CUDA="11.3"
ARG CUDNN="8"
FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

# avoid selecting 'Geographic area' during installation
ARG DEBIAN_FRONTEND=noninteractive
# avoid nvidia key issues for ubuntu 18.04
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub
RUN apt-get update && apt-get install -y gnupg2

# apt install required packages
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsm6 \
    libxext6 \
    ninja-build \
    libglib2.0-0 \
    libxrender-dev \
    libjpeg-dev \
    libpng-dev \
    git \
    wget \
    sudo \
    htop \
    tmux \
    nano \
    curl \
    openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_HTTP_DEBUG="true"
ENV CARGO_LOG="cargo::ops::registry=trace"

# Set stable as default
RUN rustup install stable && rustup default stable

# Clear any leftover Cargo registry data
RUN rm -rf /root/.cargo/registry /root/.cargo/git
RUN rustup override set nightly
# Copy your requirements
COPY requirements.txt .
# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# torch 1.11.0 would cause error
RUN pip uninstall -y torch torchvision torchaudio
RUN pip install torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 --index-url https://download.pytorch.org/whl/cu113

COPY examples/NLU /transformers
RUN cd /transformers && pip install -e .

# For Jupyter
RUN python -m ipykernel install --name docker_env --display-name "Python (Docker)"

EXPOSE 8888

WORKDIR /workspace
