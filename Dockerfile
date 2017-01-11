FROM ubuntu:xenial

RUN apt update && \
    apt install --no-install-recommends -y -qq \
      dpkg-dev \
      dput \
      git \
      golang-go && \
    rm -rf /var/lib/apt

RUN adduser --system travis && echo 'travis ALL=(ALL) ALL' >> /etc/sudoers

ENV GOPATH=/go \
    SNAPCORE_PATH=${GOPATH}/src/github.com/snapcore \
    SNAPD_PATH=${SNAPCORE_PATH}/snapd

RUN mkdir -p $SNAPCORE_PATH

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
