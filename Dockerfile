FROM ubuntu:22.04 as ton

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
        build-essential \
        curl \
        git \
        wget \
        cmake \
        clang \
        libgflags-dev \
        zlib1g-dev \
        libssl-dev \
        libreadline-dev \
        libmicrohttpd-dev \
        pkg-config \
        libgsl-dev \
        python3 \
        python3-dev \
        python3-pip \
        libsecp256k1-dev \
        libsodium-dev \
        liblz4-dev \
        ninja-build \
        fio \
        rocksdb-tools \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir psutil crc16 requests

ENV CC clang
ENV CXX clang++
ENV CCACHE_DISABLE 1
ENV OPENSSL_VERSION 3.1.4
ENV TON_VERSION master
ENV BIN_DIR /usr/bin

WORKDIR /usr/local/src

RUN wget -nv https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && tar -xf openssl-${OPENSSL_VERSION}.tar.gz \
    && cd /usr/local/src/openssl-${OPENSSL_VERSION} \
    && ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib \
    && make build_libs -j$(expr $(nproc) - 1)

WORKDIR ${BIN_DIR}/ton

RUN git clone --depth 1 --branch ${TON_VERSION} --recursive https://github.com/ton-blockchain/ton.git . \
    && mkdir ${BIN_DIR}/ton/build

WORKDIR ${BIN_DIR}/ton/build

RUN cmake -DCMAKE_BUILD_TYPE=Release -GNinja -DOPENSSL_FOUND=1 -DOPENSSL_INCLUDE_DIR=/usr/local/src/openssl-${OPENSSL_VERSION}/include -DOPENSSL_CRYPTO_LIBRARY=/usr/local/src/openssl-${OPENSSL_VERSION}/libcrypto.a .. \
    && ninja -j$(expr $(nproc) - 1) fift validator-engine lite-client validator-engine-console generate-random-id dht-server func tonlibjson rldp-http-proxy

FROM ubuntu:22.04
ENV BIN_DIR /usr/bin
ARG MYTONCTRL_VERSION=master
ARG TELEMETRY=false
ARG DUMP=false
ARG MODE=validator

RUN apt-get update \
    && apt-get install --no-install-recommends -y wget gcc libsecp256k1-dev libsodium-dev liblz4-dev python3-dev python3-pip sudo git fio iproute2 plzip pv curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/ton-work/db/static /var/ton-work/db/import

COPY --from=ton ${BIN_DIR}/ton/build/lite-client/lite-client ${BIN_DIR}/ton/lite-client/
COPY --from=ton ${BIN_DIR}/ton/build/validator-engine/validator-engine ${BIN_DIR}/ton/validator-engine/
COPY --from=ton ${BIN_DIR}/ton/build/validator-engine-console/validator-engine-console ${BIN_DIR}/ton/validator-engine-console/
COPY --from=ton ${BIN_DIR}/ton/build/utils/generate-random-id ${BIN_DIR}/ton/utils/
COPY --from=ton ${BIN_DIR}/ton/build/crypto/fift ${BIN_DIR}/ton/crypto/
COPY --from=ton ${BIN_DIR}/ton/crypto/fift/lib /usr/src/ton/crypto/fift/lib
COPY --from=ton ${BIN_DIR}/ton/crypto/smartcont /usr/src/ton/crypto/smartcont
COPY --from=ton ${BIN_DIR}/ton/.git/ /usr/src/ton/.git/

WORKDIR /usr/src/mytonctrl

RUN wget -nv https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /usr/bin/systemctl  \
    && chmod +x /usr/bin/systemctl \
    && wget -nv https://ton.org/testnet-global.config.json -O ${BIN_DIR}/ton/global.config.json \
    && git clone --depth 1 --branch ${MYTONCTRL_VERSION} --recursive https://github.com/ton-blockchain/mytonctrl.git . \
    && pip3 install --no-cache-dir -U . \
    && python3 -m mytoninstaller -u root -t ${TELEMETRY} --dump ${DUMP} -m ${MODE} \
    && ln -sf /proc/$$/fd/1 /usr/local/bin/mytoncore/mytoncore.log \
    && sed -i 's/--logname \/var\/ton-work\/log//g; s/--verbosity 1/--verbosity 3/g' /etc/systemd/system/validator.service \
    && sed -i 's/\[Service\]/\[Service\]\nStandardOutput=null\nStandardError=null/' /etc/systemd/system/validator.service \
    && sed -i 's/\[Service\]/\[Service\]\nStandardOutput=null\nStandardError=null/' /etc/systemd/system/mytoncore.service

VOLUME ["/var/ton-work", "/usr/local/bin/mytoncore"]
COPY --chmod=755 scripts/entrypoint.sh/ /scripts/entrypoint.sh
ENTRYPOINT ["/scripts/entrypoint.sh"]
