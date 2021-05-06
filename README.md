# pytorch-speedup
Speeds up pytorch by compiling it from source and provides conda package with cuda, cudnn, pytorch, torchvision

The package is created inside a docker container

## How to create package

docker, git need to be installed in the system.

```bash
git clone https://github.com/dboun/pytorch-speedup
cd pytorch-speedup
docker build -t pytorch-speedup:0.2 .

```

