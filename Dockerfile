FROM ubuntu:bionic as build

ARG MAJOR_VERSION=3
ARG MINOR_VERSION=6
ARG REQUIRED_PACKAGES="python${MAJOR_VERSION}.${MINOR_VERSION}-minimal libpython${MAJOR_VERSION}.${MINOR_VERSION}-minimal libpython${MAJOR_VERSION}.${MINOR_VERSION}-stdlib"

ENV ROOTFS /build/rootfs
ENV BUILD_DEBS /build/debs
ENV DEBIAN_FRONTEND=noninteractive

# Build pre-requisites
RUN bash -c 'mkdir -p ${BUILD_DEBS} ${ROOTFS}/{usr/local/bin}'

# Fix permissions
RUN chown -Rv 100:root $BUILD_DEBS

# Unpack required packges to rootfs
RUN apt-get update \
  && cd ${BUILD_DEBS} \
  && for pkg in $REQUIRED_PACKAGES; do \
       apt-get download $pkg \
         && apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends -i $pkg | grep '^[a-zA-Z0-9]' | xargs apt-get download ; \
     done
RUN if [ "x$(ls ${BUILD_DEBS}/)" = "x" ]; then \
      echo No required packages specified; \
    else \
      for pkg in ${BUILD_DEBS}/*.deb; do \
        echo Unpacking $pkg; \
        dpkg -x $pkg ${ROOTFS}; \
      done; \
    fi

# /usr/bin/python${MAJOR_VERSION} => /usr/bin/python${MAJOR_VERSION}.${MINOR_VERSION} symlink
RUN ln -s python${MAJOR_VERSION}.${MINOR_VERSION} ${ROOTFS}/usr/bin/python${MAJOR_VERSION}

COPY entrypoint.sh ${ROOTFS}/usr/local/bin/entrypoint.sh
RUN chmod +x ${ROOTFS}/usr/local/bin/entrypoint.sh

FROM actions/bash:4.4.18-8
LABEL maintainer = "ilja+docker@bobkevic.com"

ARG ROOTFS=/build/rootfs

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

COPY --from=build ${ROOTFS} /

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
