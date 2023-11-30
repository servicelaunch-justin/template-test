#!/bin/bash


# start_ezua_installer_ui.sh --image us.gcr.io/mapr-252711/hpe-ezua-installer-ui --tag v1.0.4

# Docker pull
REPO=marketplace.us1.greenlake-hpe.com/ezua/ezua
EZUA_INSTALLER_UI_IMAGE_NAME="hpe-ezua-installer-ui"
EZUA_INSTALLER_UI_IMAGE="${REPO}/${EZUA_INSTALLER_UI_IMAGE_NAME}"
EZUA_INSTALLER_UI_IMAGE_TAG=v1.1.0-ae17d0a24

while test -n "$1"; do
  case "$1" in
    --image)
      EZUA_INSTALLER_UI_IMAGE="$2"
      shift 2
      ;;
    --tag)
      EZUA_INSTALLER_UI_IMAGE_TAG=v1.1.0-ae17d0a24
      shift 2
      ;;
  esac
done

EZUA_INSTALLER_CONTAINER="${EZUA_INSTALLER_UI_IMAGE}:${EZUA_INSTALLER_UI_IMAGE_TAG}"

DOCKER_MIN_VERSION="20.10.0"
if [ -z "$NO_PROXY" ]; then
  NO_PROXY="host.docker.internal"
else
  NO_PROXY="host.docker.internal,$NO_PROXY"
fi

ver_check() {
  local arr1=(${1//./ })
  local arr2=(${2//./ })
  for i in {0..2}; do
    if [[ ${arr1[i]} -lt ${arr2[i]} ]]; then
      return 1
    elif [[ ${arr1[i]} -gt ${arr2[i]} ]]; then
      return 0
    fi
  done
  return 1
}

echo "Starting install of HPE Ezmeral Unified Analytics"
echo "Note: If lauching behind a corporate proxy, ensure HTTP_PROXY, HTTPS_PROXY, and NO_PROXY are set properly before continuing"
read -p "Do you want to continue? [y/n]: " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo $'\nStopping installer'
    exit 1
fi
echo $'\nStarting installer'

echo "Checking Docker Install"
docker version > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "Docker not installed. Please install Docker first"
  exit 1
fi
DOCKER_CLIENT_VERSION=`docker version --format '{{.Client.Version}}'`
if ver_check $DOCKER_MIN_VERSION $DOCKER_CLIENT_VERSION; then
  echo "ERROR: Your version of Docker Client is $DOCKER_CLIENT_VERSION but the minimum version of Docker required is $DOCKER_MIN_VERSION"
  exit 1
fi
DOCKER_SERVER_VERSION=`docker version --format '{{.Server.Version}}'`
if ver_check $DOCKER_MIN_VERSION $DOCKER_SERVER_VERSION; then
  echo "ERROR: Your version of Docker Server is $DOCKER_SERVER_VERSION but the minimum version of Docker required is $DOCKER_MIN_VERSION"
  exit 1
fi

if [[ "$(docker images -q ${EZUA_INSTALLER_CONTAINER} 2> /dev/null)" != "" ]]; then
  echo "Downloading image, this may take some time."
  docker pull ${EZUA_INSTALLER_CONTAINER} > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "ERROR: Could not pull installer image. Ensure installer has access to ${EZUA_INSTALLER_CONTAINER}"
    exit 1
  fi
fi

docker run -d --restart always -t -p 8080:8080 --privileged \
    -e HTTPS_PROXY="${HTTPS_PROXY}" -e HTTP_PROXY="${HTTP_PROXY}" -e NO_PROXY="${NO_PROXY}" \
    --name="${EZUA_INSTALLER_UI_IMAGE_NAME}" $EZUA_INSTALLER_CONTAINER
if [[ $? -eq 0 ]]; then
  echo "HPE Ezmeral Unified Analytics Software is ready to install at: http://localhost:8080"
  exit 0
else
  echo "HPE Ezmeral Unified Analytics Software Installer failed. Check your docker is running and port 8080 is unused."
  exit 1
fi
