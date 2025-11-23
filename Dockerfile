FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# 1. Системные пакеты
RUN apt-get update && apt-get install -y \
    git wget unzip python3 build-essential \
    gcc-arm-none-eabi libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib libsdl2-dev xxd \
    && rm -rf /var/lib/apt/lists/*

# 2. Установка CMake 3.31.5 (как в рабочем варианте)
WORKDIR /opt
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.5/cmake-3.31.5-linux-x86_64.tar.gz && \
    tar xf cmake-3.31.5-linux-x86_64.tar.gz && \
    ln -s /opt/cmake-3.31.5-linux-x86_64/bin/* /usr/local/bin/

# 3. Клонируем pico-mac и pico-sdk
RUN git clone --recursive https://github.com/evansm7/pico-mac && \
    git clone --recursive https://github.com/raspberrypi/pico-sdk

ENV PICOMAC=/opt/pico-mac
ENV PICOSDK=/opt/pico-sdk

# 4. Подготовка рабочей директории
WORKDIR /opt/pico-mac

# 5. Копируем entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
