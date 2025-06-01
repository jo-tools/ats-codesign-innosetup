# BASE IMAGE
FROM debian:bookworm-slim

# ARGUMENTS IN BUILD STAGE
ARG DEBIAN_FRONTEND=noninteractive

# ENVIRONMENT
ENV TZ=Etc/UTC \
	DEBIAN_FRONTEND=noninteractive \
	WINEARCH=win32 \
	DISPLAY=:0 \
	INNOSETUP_VERSION=6.4.3 \
	JSIGN_VERSION=7.1

# INSTALL WINE AND REQUIRED PACKAGES
RUN dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		tzdata \
        curl \
        ca-certificates \
		jq \
		default-jdk \
		procps \
		xvfb \
		wine \
		wine32

# SETUP HELPER SCRIPTS
RUN mkdir -p /opt/bin \
	&& echo '#!/bin/sh' > ./waitonproc \
	&& echo 'COUNT=0' >> ./waitonproc \
	&& echo 'echo "Start waiting on $@"' >> ./waitonproc \
	&& echo 'while pgrep "$@" > /dev/null; do ' >> ./waitonproc \
	&& echo '	echo "waiting ..."' >> ./waitonproc \
	&& echo '	sleep 1; ' >> ./waitonproc \
	&& echo '	COUNT=$((COUNT+1))' >> ./waitonproc \
	&& echo '	if [ $COUNT -eq 60 ]; then' >> ./waitonproc \
	&& echo '		exit 3;' >> ./waitonproc \
	&& echo '	fi' >> ./waitonproc \
	&& echo 'done' >> ./waitonproc \
	&& echo 'echo "$@ completed"' >> ./waitonproc \
	&& chmod +x ./waitonproc \
	\
	&& echo '#!/bin/sh' > ./wine-xvfb \
	&& echo 'Xvfb $DISPLAY &' >> ./wine-xvfb \
	&& echo 'tokill=$!' >> ./wine-xvfb \
	&& echo 'wine wineboot --init' >> ./wine-xvfb \
	&& echo 'waitonprocess wineserver' >> ./wine-xvfb \
	&& echo '"$@"' >> ./wine-xvfb \
	&& echo 'retval=$?' >> ./wine-xvfb \
	&& echo 'kill -15 $tokill' >> ./wine-xvfb \
	&& echo 'wine wineboot --shutdown' >> ./wine-xvfb \
	&& echo 'return $retval' >> ./wine-xvfb \
	&& chmod +x ./wine-xvfb

# WINE: SHOW DOT FILES
RUN wine reg add 'HKEY_CURRENT_USER\Software\Wine' /v ShowDotFiles /d Y \
	&& while [ ! -f ~/.wine/user.reg ]; do sleep 1; done

# INSTALL INNOSETUP ON WINE
RUN curl -sL https://files.jrsoftware.org/is/6/innosetup-${INNOSETUP_VERSION}.exe -o ./innosetup.exe \
    && ./wine-xvfb wine innosetup.exe /SP- /VERYSILENT /ALLUSERS /SUPPRESSMSGBOXES \
    && rm ./innosetup.exe

# Clean up
RUN rm ./waitonproc \
	&& rm ./wine-xvfb \
	&& apt-get purge --auto-remove -y \
		procps \
		xvfb \
	&& apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists

# INSTALL jsign
RUN curl -sL https://github.com/ebourg/jsign/releases/download/${JSIGN_VERSION}/jsign_${JSIGN_VERSION}_all.deb -o ./jsign.deb \
	&& dpkg --install ./jsign.deb \
	&& rm ./jsign.deb

# INSTALL Azure CLI
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# COPY JOTOOLS SCRIPTS
COPY ./scripts /usr/local/bin

# CHMOD JOTOOLS SCRIPTS EXECUTABLE
RUN chmod 755 /usr/local/bin/ats-codesign.sh \
	&& chmod 755 /usr/local/bin/ats-codesign-wine.sh \
	&& chmod 755 /usr/local/bin/ats-codesign.bat \
	&& chmod 755 /usr/local/bin/pfx-codesign.sh \
	&& chmod 755 /usr/local/bin/pfx-codesign-wine.sh \
	&& chmod 755 /usr/local/bin/pfx-codesign.bat \
	&& chmod 755 /usr/local/bin/iscc.sh

# PREPARE CONTAINER
RUN mkdir -p /etc/ats-codesign \
	&& mkdir -p /etc/pfx-codesign \
	&& mkdir -p /data
WORKDIR /data
