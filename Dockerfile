FROM alpine:3.11.5 AS base-image

# Allow HOME to be set at runtime
ENV HOME /tmp

# Runtime can set GIT_CRYPT_PATH to the path to the docker wrapper script in
# the repo
ENV GIT_CRYPT_PATH=""

#
# Base layer - install packages needed in final image
#
RUN apk --update add \
    git \
    bash \
    libstdc++ \
    gnupg \
    openssl \
  && rm -rf /var/cache/apk/*

#
# Build layer
#
FROM base-image AS build

ARG VERSION=0.6.0

RUN apk --update add \
    bash \
    curl \
    g++ \
    make \
    openssl-dev \
  && rm -rf /var/cache/apk/*

WORKDIR /usr/src/git-crypt
RUN curl -L https://github.com/AGWA/git-crypt/archive/$VERSION.tar.gz | tar zxv \
  && cd git-crypt-$VERSION \
  && make -j$(nproc) \
  && make install PREFIX=/usr/local

#
# Final image layer
#
FROM base-image

COPY --from=build /usr/local/bin/git-crypt /usr/local/bin/git-crypt
ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
