#DOCKER BUILD ARGUMENTS
ARG ARCH

#BASE IMAGE
FROM ${ARCH:-amd64}/ubuntu:24.04

#ARGUMENTS IN BUILD STAGE
ARG ARCH
ARG BUILDPLATFORM

#ENVIRONMENT
ENV TZ=Etc/UTC

#INSTALL REQUIRED LIBRARIES
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
		tzdata \
		ca-certificates \
		curl \
		jq \
		openjdk-21-jdk-headless

RUN curl -L -O https://github.com/ebourg/jsign/releases/download/7.1/jsign_7.1_all.deb && \
		dpkg --install ./jsign_7.1_all.deb && \
		rm ./jsign_7.1_all.deb

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

#COPY CODESIGN SCRIPT
COPY ./ats-codesign.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/ats-codesign.sh

#PREPARE CONTAINER
RUN mkdir -p /etc/ats-codesign
RUN mkdir -p /data
WORKDIR /data
