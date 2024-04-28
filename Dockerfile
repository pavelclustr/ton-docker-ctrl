FROM ubuntu:20.04

ARG GLOBAL_CONFIG_URL
ARG TELEMETRY
ARG IGNORE_MINIMAL_REQS
ARG DUMP

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y locales cmake make git wget python3-dev python3-pip python3-wheel nano htop iproute2

# Add scripts
ADD scripts/ /scripts/

# Install systemctl
RUN wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py \
     -O /usr/bin/systemctl && chmod +x /usr/bin/systemctl

# Install mytonstrl
RUN wget https://raw.githubusercontent.com/ton-blockchain/mytonctrl/mytonctrl2/scripts/install.sh 
RUN /bin/bash /scripts/eval_and_install.sh

# Patch mytoncrtl
RUN python3 /scripts/patch_baseline.py

WORKDIR /root

ENTRYPOINT ["/scripts/entrypoint.sh"]