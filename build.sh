#$PYTHON setup.py install

pip install torch==1.8.1+cu102 -f https://download.pytorch.org/whl/torch_stable.html

export TORCH_CUDA_ARCH_LIST="6.1;7.0;7.5;8.0"

# Clone torchvision
export CUDA_HOME=/root/anaconda3/pkgs/cudatoolkit-10.2.89-hfd86e86_1
export PYTORCHVISION_VERSION=v0.9.1
git clone https://github.com/pytorch/vision.git
cd vision
git checkout ${PYTORCHVISION_VERSION}

# Build torchvision
MAX_JOBS=8 FORCE_CUDA=1 $PYTHON setup.py install
