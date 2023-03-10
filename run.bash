sudo xhost +local:docker
export XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH 
fi

docker build -t kuka_image . 

docker run -it \
    --net=host \
    --privileged \
    --gpus all \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env=NVIDIA_DRIVER_CAPABILITIES=all \
    --env=NVIDIA-VISIBLE_DEVICES=all \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -v="/home/faster/Desktop/kuka/files:/kuka" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --runtime=nvidia \
    kuka_image \
    bash
