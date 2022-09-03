# FROM docker:stable-dind

FROM docker
# Add buildx in case we need it 
COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

# demo
ENV DOCKER_BUILDKIT=1
ARG REPOSITORY='markdrew'
ARG TOMCAT_VERSION='9.0'
ARG TOMCAT_JAVA_VERSION='jdk8-openjdk'
ARG TOMCAT_BASE_IMAGE=''
ARG LUCEE_VERSION='5.3.7.47'
ARG LUCEE_MINOR='5.3'
ARG LUCEE_SERVER=''
ARG LUCEE_VARIANT='-light'
ARG LUCEE_SERVER='-nginx'

ENV REPOSITORY=${REPOSITORY}
ENV TOMCAT_VERSION=${TOMCAT_VERSION}
ENV TOMCAT_JAVA_VERSION=${TOMCAT_JAVA_VERSION}
ENV TOMCAT_BASE_IMAGE=${TOMCAT_BASE_IMAGE}
ENV LUCEE_VERSION=${LUCEE_VERSION}
ENV LUCEE_MINOR=${LUCEE_MINOR}
ENV LUCEE_SERVER=${LUCEE_SERVER}
ENV LUCEE_VARIANT=${LUCEE_VARIANT}
ENV LUCEE_SERVER=${LUCEE_SERVER}

WORKDIR /
ADD https://github.com/lucee/lucee-dockerfiles/archive/refs/heads/master.zip lucee-dockerfiles.zip
RUN unzip lucee-dockerfiles.zip && mv lucee-dockerfiles-master /lucee-dockerfiles && rm -rf git
COPY ./build_lucee.sh /build_lucee.sh
RUN chmod +x /build_lucee.sh
ENTRYPOINT ["/build_lucee.sh"]