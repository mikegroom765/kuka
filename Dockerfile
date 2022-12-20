FROM osrf/ros:kinetic-desktop

# Dependencies for glvnd and X11.
RUN apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
  && rm -rf /var/lib/apt/lists/*

  # nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,utility,compute

# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]

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
    && apt-get install -y ros-kinetic-joint-state-publisher-gui

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
    && rosdep update \
    && cd catkin_ws/src \
    && git clone https://github.com/ros-industrial/kuka_experimental.git \
    && cd .. \
    && rosdep install -y --from-paths src --ignore-src \
    && catkin_make

WORKDIR /catkin_ws