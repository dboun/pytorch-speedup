echo ">>>>>Building..." && \
    cd /repo/src/pytorch && \
    export CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" && \
    USE_NINJA=OFF MAX_JOBS=8 FORCE_CUDA=1 $PYTHON setup.py install 
echo ">>>>>Finished"