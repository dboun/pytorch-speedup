FROM centos:centos7

### ---- Install anaconda ----

RUN yum install bzip2 -y # needed for conda
RUN cd /tmp && \
    curl -O https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh && \
    bash Anaconda3-5.3.1-Linux-x86_64.sh -b
ENV CONDA /root/anaconda3/bin/conda
RUN $CONDA create --name buildenv -y
ENV CONDAENVDIR /root/anaconda3/envs/buildenv
ENV ACTIVATE_CONDA ". /root/anaconda3/etc/profile.d/conda.sh"
ENV ACTIVATE_CONDA_ENV "conda activate $CONDAENVDIR"
RUN $ACTIVATE_CONDA && conda update conda

### ---- Install gcc 7.2.0 from source ----

RUN yum group install "Development Tools" -y
RUN curl -O http://ftp.gnu.org/gnu/gcc/gcc-7.2.0/gcc-7.2.0.tar.gz
RUN tar -zxvf gcc-7.2.0.tar.gz
RUN cd gcc-7.2.0 && ./contrib/download_prerequisites && \
    mkdir gcc-build-7.2.0 && cd gcc-build-7.2.0 && \
    ../configure -enable-checking=release -enable-languages=c,c++ -disable-multilib && \
    yum groupinstall "Development Tools" && \
    make && make install

### ---- Install binutils/2.34 ----

RUN yum install -y https://rpmfind.net/linux/fedora/linux/releases/32/Everything/x86_64/os/Packages/b/binutils-2.34-2.fc32.x86_64.rpm

### ---- Package ----

### PyTorch dependencies
RUN $ACTIVATE_CONDA && $ACTIVATE_CONDA_ENV && conda install conda-build -y
#RUN $ACTIVATE_CONDA && $ACTIVATE_CONDA_ENV && conda install \
#	conda-build \
#	numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing_extensions future six requests dataclasses \
#	ipython pkg-config \
#	-y

### Create package
RUN mkdir -p /opt/repo
WORKDIR /opt/repo
COPY . .
RUN $SHELL_WITH_DEVTOOLSET7 && $ACTIVATE_CONDA && $ACTIVATE_CONDA_ENV && conda-build . -c anaconda
