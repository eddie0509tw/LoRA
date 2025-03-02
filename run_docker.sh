WORKSPACE_DIR="./"
IMAGE_NAME=loratest
IMAGE_VERSION=latest

docker run -it --rm --gpus all --ipc=host --ulimit memlock=-1 \
    --network="host" \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/.Xauthority:/root/.Xauthority \
    -v ./:/workspace \
    -v /mnt/datasets:/workspace/datasets \
    $IMAGE_NAME:$IMAGE_VERSION \
    jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --NotebookApp.token=''