### Install cuda and cudnn
echo "Installing CUDA 11.3 and CuDNN 8.1"

## CUDA
rm -rf $PREFIX/usr/local/cuda-11.3 $PREFIX/usr/local/cuda
# install CUDA 11.3 in the same container
wget -q https://developer.download.nvidia.com/compute/cuda/11.3.0/local_installers/cuda_11.3.0_465.19.01_linux.run
chmod +x cuda_11.3.0_465.19.01_linux.run
./cuda_11.3.0_465.19.01_linux.run --silent --toolkit --toolkitpath=$PREFIX/usr/local
rm -f cuda_11.3.0_465.19.01_linux.run
rm -f $PREFIX/usr/local/cuda && ln -s $PREFIX/usr/local/cuda-11.3 $PREFIX/usr/local/cuda
export PATH=$PREFIX/usr/local/bin/:$PATH
export LD_LIBRARY_PATH=$PREFIX/usr/local/lib64/:$LD_LIBRARY_PATH
export CUDA_HOME=$PREFIX/usr/local/cuda

## CuDNN
# cuDNN license: https://developer.nvidia.com/cudnn/license_agreement
mkdir tmp_cudnn && cd tmp_cudnn
wget -q https://developer.download.nvidia.com/compute/redist/cudnn/v8.2.0/cudnn-11.3-linux-x64-v8.2.0.53.tgz -O cudnn-8.2.tgz
tar xf cudnn-8.2.tgz
cp -a cuda/include/* $PREFIX/usr/local/cuda/include/
cp -a cuda/lib64/* $PREFIX/usr/local/cuda/lib64/
cd ..
rm -rf tmp_cudnn
ldconfig

### Install pytorch

echo ">>>>>Building..." && \
    cd /repo/src/pytorch && \
    export CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" && \
    USE_NINJA=OFF MAX_JOBS=8 FORCE_CUDA=1 $PYTHON setup.py install 
    # && \
    # cd /repo/src/vision && \
    # MAX_JOBS=8 FORCE_CUDA=1 $PYTHON setup.py install

echo ">>>>>Finished"