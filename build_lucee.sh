#!/bin/sh
echo "Building the images"
cd lucee-dockerfiles

# These are he variables required. They are set in the Dockerfile.builder 

# TOMCAT_VERSION=${9.0'
# TOMCAT_JAVA_VERSION=${jdk8-openjdk'
# TOMCAT_BASE_IMAGE=${'
# LUCEE_VERSION=${5.3.7.47'
# LUCEE_MINOR=${5.3'
# LUCEE_SERVER=${'
# LUCEE_VARIANT=${-light'
# LUCEE_SERVER=${-nginx'

LUCEE_JAR_URL="https://cdn.lucee.org/lucee-light-${LUCEE_VERSION}.jar"
TAG_LUCEE_TOMCAT="${REPOSITORY}/lucee:${LUCEE_VERSION}${LUCEE_VARIANT}${LUCEE_SERVER}-tomcat${TOMCAT_VERSION}-${TOMCAT_JAVA_VERSION}"
docker pull docker.io/library/tomcat:${TOMCAT_VERSION}-${TOMCAT_JAVA_VERSION}${TOMCAT_BASE_IMAGE}
echo "Downloaded Tomcat Base Image. It's an..."
docker inspect docker.io/library/tomcat:${TOMCAT_VERSION}-${TOMCAT_JAVA_VERSION}${TOMCAT_BASE_IMAGE} | grep  'Architecture'

docker build \
    --build-arg TOMCAT_VERSION=${TOMCAT_VERSION} \
    --build-arg TOMCAT_JAVA_VERSION=${TOMCAT_JAVA_VERSION} \
    --build-arg TOMCAT_BASE_IMAGE=${TOMCAT_BASE_IMAGE} \
    --build-arg LUCEE_VERSION=${LUCEE_VERSION} \
    --build-arg LUCEE_MINOR=${LUCEE_MINOR} \
    --build-arg LUCEE_SERVER=${LUCEE_SERVER} \
    --build-arg LUCEE_VARINT=${LUCEE_VARIANT} \
    --build-arg LUCEE_JAR_URL=${LUCEE_JAR_URL} \
    -f Dockerfile -t $TAG_LUCEE_TOMCAT .
echo "Built Lucee Base Image It's an..."
docker inspect  $TAG_LUCEE_TOMCAT | grep  'Architecture'



TAG_LUCEE_NGINX="markdrew/lucee:${LUCEE_VERSION}${LUCEE_VARIANT}${LUCEE_SERVER}-tomcat${TOMCAT_VERSION}-${TOMCAT_JAVA_VERSION}"
echo "Now to build the nginx version. I feel dirty about this"
docker build \
    --build-arg LUCEE_IMAGE=${TAG_LUCEE_TOMCAT} \
    -f Dockerfile.nginx -t $TAG_LUCEE_NGINX .
docker inspect  $TAG_LUCEE_NGINX | grep 'Architecture'

echo "🚀🚀🚀 Built the following images:"
echo "----- $TAG_LUCEE_TOMCAT"
echo "----- $TAG_LUCEE_NGINX"
echo "🎉 These are available on the host with by running [docker images] 🎉"

exit;

# ********************************
# THE EXTRA BIT! THIS WOULD DO MULTI PLATFORM BUILDS AND PUSH THEM TO A REPO. 
# TAKES A LONG TIME AS tomcat hangs when building AMD  version on ARM(M1)
# ********************************
# echo "Build Ben's Dockerfile"
# docker build \
#     --build-arg IMAGE_FILE=$LUCEE_NGINXTAG \
#     -f Dockerfile.ben -t markdrew/ben_app .
# docker inspect  markdrew/ben_app | jq '.[].Architecture'

# platforms="linux/arm64"
platforms="linux/amd64,linux/arm64"
echo "🚀🚀🚀 Do the multi platform build for platforms: [$platforms]"
echo " ⚙ Creating the builder [dkbuilder]:"
docker buildx rm dkbuilder
docker buildx create --name dkbuilder --append --use --platform ${platforms}
docker buildx inspect dkbuilder
docker buildx use dkbuilder
echo " 🛠 Building ${TAG_LUCEE_TOMCAT}"

docker buildx build --platform ${platforms} \
    --build-arg TOMCAT_VERSION=${TOMCAT_VERSION} \
    --build-arg TOMCAT_JAVA_VERSION=${TOMCAT_JAVA_VERSION} \
    --build-arg TOMCAT_BASE_IMAGE=${TOMCAT_BASE_IMAGE} \
    --build-arg LUCEE_VERSION=${LUCEE_VERSION} \
    --build-arg LUCEE_MINOR=${LUCEE_MINOR} \
    --build-arg LUCEE_SERVER=${LUCEE_SERVER} \
    --build-arg LUCEE_VARINT=${LUCEE_VARIANT} \
    --build-arg LUCEE_JAR_URL=${LUCEE_JAR_URL} \
    -f Dockerfile -t $TAG_LUCEE_TOMCAT --push .

echo " 🛠 Building ${TAG_LUCEE_NGINX}"
docker buildx build --platform ${platforms} \
    --build-arg LUCEE_IMAGE=${TAG_LUCEE_TOMCAT} \
    -f Dockerfile.nginx -t $TAG_LUCEE_NGINX --push .