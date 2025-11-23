FROM ubuntu:22.04

RUN apt update && apt install -y \
    build-essential \
    python3 \
    git \
    wget \
    unzip \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    libsdl2-dev \
    xxd \
    && rm -rf /var/lib/apt/lists/*

# Install CMake 3.31.5 exactly as in working instructions
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.5/cmake-3.31.5-linux-x86_64.tar.gz \
    && tar xf cmake-3.31.5-linux-x86_64.tar.gz \
    && mv cmake-3.31.5-linux-x86_64 /opt/cmake

ENV PATH="/opt/cmake/bin:${PATH}"

# Clone PicoMac & PicoSDK exactly as instructions
RUN git clone --recursive https://github.com/evansm7/pico-mac /opt/pico-mac && \
    git clone --recursive https://github.com/raspberrypi/pico-sdk /opt/pico-sdk

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /opt/pico-mac

ENTRYPOINT ["/entrypoint.sh"]
