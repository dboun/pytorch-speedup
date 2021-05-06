#$PYTHON setup.py install
#pip install torch==1.8.1+cu102 -f https://download.pytorch.org/whl/torch_stable.html
# export TORCH_CUDA_ARCH_LIST="6.1;7.0;7.5;8.0"

# export CUDA_HOME=/root/anaconda3/pkgs/cudatoolkit-10.2.89-hfd86e86_1

### Dummy file
# mkdir -p $PREFIX/bin
# echo 'print("hi!")' > ex1234.py
# cp ex1234.py $PREFIX/bin/ex1234.py

echo ">>>>>Building..." && \
    cd /repo/src/pytorch && \
    export CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" && \
    USE_NINJA=OFF MAX_JOBS=8 FORCE_CUDA=1 $PYTHON setup.py install 
    # && \
    # cd /repo/src/vision && \
    # MAX_JOBS=8 FORCE_CUDA=1 $PYTHON setup.py install

echo ">>>>>Finished"