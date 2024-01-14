# See more details about this base image in
# https://github.com/tiangolo/uvicorn-gunicorn-fastapi-docker
#FROM tiangolo/uvicorn-gunicorn-fastapi:python3.10

# Start from NVIDIA's CUDA 11.0 base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

RUN apt-get clean

# Check if the CUDA repository configuration exists, then backup and modify it
RUN if [ -f /etc/apt/sources.list.d/cuda.list ]; then \
        cp /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/cuda.list.backup && \
        sed -i 's/^deb /# deb /' /etc/apt/sources.list.d/cuda.list; \
    fi


RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y python3.10 python3-pip python3.10-distutils curl \
    && apt-get install -y libgl1-mesa-glx nginx git

# Make Python 3.10 the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Download and run get-pip.py for Python 3.10
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py

COPY . /

RUN pip3 install --no-cache-dir -r requirements.txt
RUN pip3 install torch==2.0.0+cu118 torchaudio==2.0.0+cu118 torchvision==0.15.0+cu118 --extra-index-url https://download.pytorch.org/whl/cu118
RUN pip3 install nvidia-ml-py

RUN chmod +x /webui.sh

CMD ["/webui.sh", "--share", "--listen", "--api"]