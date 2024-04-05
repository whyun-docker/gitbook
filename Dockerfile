FROM lscr.io/linuxserver/calibre:latest  AS build-stage
ENV NODE_VERSION=10.24.1
ENV DEBIAN_FRONTEND noninteractive
RUN ebook-convert --version
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
  && sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
  && apt-get update \
  && apt-get install --force-yes --no-install-recommends curl fonts-wqy-microhei \
  libgl1-mesa-glx  libegl1 libxkbcommon0 libopengl0 -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

SHELL ["/bin/bash", "-c"]
ARG NPM_REGISTRY=https://registry.npmmirror.com
ARG NPM_MIRROR=https://npmmirror.com
RUN if [ "$TARGETARCH" = "arm64" ] ; then \
    export ARCH=arm64 ; \
  elif [ "$TARGETARCH" = "arm" ] ; then \
    export ARCH=armv7l ; \
  else \
    export ARCH=x64 ; \
  fi ; \
  if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "arm" ] ; then \
    apt-get update \
    && apt-get install libatomic1 --no-install-recommends -y \
    && rm -rf /var/lib/apt/lists/* ; \
  fi \
  && curl -fsSLO --compressed "${NPM_MIRROR}/mirrors/node/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.gz" \
  && curl -fsSLO --compressed "${NPM_MIRROR}/mirrors/node/v$NODE_VERSION/SHASUMS256.txt" \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.gz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -zxvf "node-v$NODE_VERSION-linux-$ARCH.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.gz" SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && npm config set registry ${NPM_REGISTRY}

RUN which node ; node -v; npm install gitbook-cli -g
RUN gitbook fetch  3.2.3

RUN useradd -ms /bin/bash gitbook
RUN chown gitbook:gitbook -R /opt

USER gitbook
RUN gitbook current