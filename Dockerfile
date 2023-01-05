FROM nvidia/cudagl:10.2-devel-ubuntu16.04

# Dependencies for glvnd and X11.

  # nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,utility,compute

# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]


# Install ros kinetic

RUN apt-get update && apt-get install -y lsb-release gnupg2 curl

RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN apt-get update && apt-get install -y ros-kinetic-desktop-full

RUN apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

# # Change the default shell to Bash
# SHELL [ "/bin/bash" , "-c" ]

# RUN apt-get update && \
#       apt-get -y install -y sudo \
#       && sudo apt install -y lsb-core

# RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
# RUN sudo apt install -y curl 
# # if you haven't already installed curl
# RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

# RUN sudo apt-get update && sudo apt-get install -y ros-kinetic-desktop-full

RUN apt-get update && apt-get install -y git \
    && apt-get install -y ros-kinetic-joint-state-publisher-gui \
    && apt-get install -y ros-kinetic-ros-control ros-kinetic-ros-controllers \
    && apt-get install -y ros-kinetic-industrial-core
# Create a Catkin workspace and clone demo code
RUN source /opt/ros/kinetic/setup.bash \
    && mkdir -p /catkin_ws/src \
    && cd /catkin_ws/src \
    && catkin_init_workspace 
    
# Build the Catkin workspace and ensure it's sourced

RUN source /opt/ros/kinetic/setup.bash \
    && cd catkin_ws \
    && catkin_make \
    && source /catkin_ws/devel/setup.bash
    
RUN echo "source /catkin_ws/devel/setup.bash" >> ~/.bashrc

RUN source /opt/ros/kinetic/setup.bash \
    && sudo rosdep init \
    && rosdep update

RUN cd /catkin_ws/src \
    && git clone https://github.com/ros-industrial/kuka_experimental.git

RUN cd /catkin_ws \
    && source /opt/ros/kinetic/setup.bash \
    && source /catkin_ws/devel/setup.bash \
    && rosdep install -y --from-paths src --ignore-src \
    && catkin_make

WORKDIR /catkin_ws