FROM ubuntu:20.04
RUN apt-get update -y && apt-get upgrade -y

### ---- Install conda ----

RUN apt-get install bzip2 curl -y
RUN cd /tmp && \
    curl -O https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh && \
    bash Anaconda3-5.3.1-Linux-x86_64.sh -b
ENV CONDA /root/anaconda3/bin/conda
ENV ACTIVATE_CONDA ". /root/anaconda3/etc/profile.d/conda.sh"
RUN $ACTIVATE_CONDA && conda update conda
# For easier testing (ignore this)
RUN $CONDA create --name testenv python=3.6 -y
# env
RUN $CONDA create --name buildenv python=3.6 -y
ENV CONDA_ENV_DIR /root/anaconda3/envs/buildenv
ENV ACTIVATE_CONDA_ENV "conda activate $CONDA_ENV_DIR"
### interactive shell
RUN echo "${ACTIVATE_CONDA} && ${ACTIVATE_CONDA_ENV}" >> ~/.bashrc

### ---- Install gcc & binutils & git ----

RUN apt-get install git gcc-7 binutils-dev -y

### ---- Clone repos ----

RUN mkdir -p /repo
WORKDIR /repo

# matches nnDetection
ENV PYTORCH_VERSION "v1.8.1"
# torchvision
ENV PYTORCHVISION_VERSION "v0.9.1"
# arch
ENV TORCH_CUDA_ARCH_LIST "6.1;7.0;7.5;8.0"

RUN mkdir -p src

# Clone pytorch
RUN cd /repo/src && \
    git clone https://github.com/pytorch/pytorch.git && \
    cd pytorch && \
    git checkout ${PYTORCH_VERSION}  && \
    git submodule sync  && \
    git submodule update --init --recursive

# # Clone torchvision
# RUN cd /repo/src && \
#     git clone https://github.com/pytorch/vision.git && \
#     cd vision && \
#     git checkout ${PYTORCHVISION_VERSION}

# ---- Package ----

### PyTorch dependencies

RUN $ACTIVATE_CONDA && $ACTIVATE_CONDA_ENV && conda install conda-build conda-verify -y

# For caching reasons
RUN $ACTIVATE_CONDA && $ACTIVATE_CONDA_ENV && conda install \
    python \
    pip \
    setuptools \
    # cudnn=7.6.5=cuda10.2_0 \
    numpy \ 
    ninja \ 
    pyyaml \ 
    mkl \ 
    mkl-include \ 
    setuptools \
    cmake \ 
    cffi \ 
    typing_extensions \ 
    future \ 
    six \ 
    requests \ 
    dataclasses \ 
    ipython \ 
    pkg-config \
    magma-cuda113 \
    -c pytorch -y
    # -c anaconda

# ENV CUDA_HOME="/root/anaconda3/pkgs/cudatoolkit-10.2.89-hfd86e86_1"
# ENV PATH="${CUDA_HOME}/lib:/root/anaconda3/envs/buildenv/bin:/root/anaconda3/envs/buildenv/lib:/usr/local/lib:${PATH}"
# ENV LD_LIBRARY_PATH="${CUDA_HOME}/lib:/root/anaconda3/envs/buildenv/lib:/usr/local/lib:$LD_LIBRARY_PATH"
# ENV LIBRARY_PATH="${CUDA_HOME}/lib:/root/anaconda3/envs/buildenv/lib:/usr/local/lib:$LIBRARY_PATH"
# ENV CPATH="${CUDA_HOME}/lib:/root/anaconda3/envs/buildenv/lib:/usr/local/lib:$CPATH"
# ENV PATH="${CUDA_HOME}/bin:$PATH"
# ENV LD_LIBRARY_PATH="${CUDA_HOME}/lib:$LD_LIBRARY_PATH"
# # env cudnn
# ENV CUDNN_LIBRARY_PATH /root/anaconda3/pkgs/cudnn-7.6.5-cuda10.2_0/lib
# ENV CUDNN_LIBRARY /root/anaconda3/pkgs/cudnn-7.6.5-cuda10.2_0/lib
# ENV CUDNN_INCLUDE_DIR /root/anaconda3/pkgs/cudnn-7.6.5-cuda10.2_0/include
# ENV LD_LIBRARY_PATH /root/anaconda3/pkgs/cudnn-7.6.5-cuda10.2_0/lib:$LD_LIBRARY_PATH

COPY . .
# RUN touch __init__.py

RUN apt-get install build-essential wget -y
RUN apt-get install libxml2-dev

# Build package
# RUN $ACTIVATE_CONDA && $ACTIVATE_CONDA_ENV && conda-build . -c pytorch -c conda-forge
#-c anaconda 

# Copy results
RUN mkdir -p /root/anaconda3/envs/buildenv/conda-bld
RUN mkdir -p /output
RUN yes | /bin/cp -r /root/anaconda3/envs/buildenv/conda-bld /output

### For reference
#conda install --use-local --update-deps my-package-name -c anaconda
#conda install pytorch-speedup-0.1-py37_0.tar.bz2
#conda update pytorch-speedup # -> install deps