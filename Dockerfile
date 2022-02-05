FROM arm64v8/ubuntu:latest

RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y curl gnupg lsb-release && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo 'deb [arch=arm64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu focal main' >> /etc/apt/sources.list.d/ros2.list 

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  ack \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-flake8 \
  python3-pip \
  python3-pytest-cov \
  python3-rosdep \
  python3-setuptools \
  python3-vcstool \
  tmux \
  vim \
  wget

RUN python3 -m pip install -U \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest \
  setuptools

RUN mkdir -p /root/ros2_galactic/src

WORKDIR /root/ros2_galactic

RUN wget https://raw.githubusercontent.com/ros2/ros2/galactic/ros2.repos

RUN vcs import src < ros2.repos

RUN rosdep init

RUN rosdep update

RUN rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-5.3.1 urdfdom_headers"

RUN colcon build --symlink-install

RUN apt-get update && apt install -y \
  ros-galactic-turtlesim \
  ~nros-galactic-rqt*
