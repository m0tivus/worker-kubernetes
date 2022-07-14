#!/bin/sh


if [ $# -lt 4 ]
  then
    echo "Not enough arguments. Usage: ./build_tag_release.sh ocir_user env region tenancy_hash"
    echo "Example: ./build_tag_release.sh service_user prd01 sa-santiago-1 axyvvilklpqv"
    exit 1

else
export APP_NAME="${PWD##*/}"
export ENV=$2
export REGION=$3.ocir.io
export TENANCY_HASH=$4
export OCIR_USER=$TENANCY_HASH/$1

  echo "Enter OCIR Token"
  read -r OCIR_PASSWORD   

  echo "--- login into OCIR ---"
  echo ${OCIR_PASSWORD} | docker login -u ${OCIR_USER} --password-stdin ${REGION}  

  if [ $? -eq 1 ]
   then  
    echo "--- incorrect credentials. Try again"
    exit 1
  else

    echo "--- pruning images ---"
    docker system prune -f -a

    echo "--- building image ${APP_NAME}:latest ---"
    docker-compose build

    echo "--- tag image ${APP_NAME}:latest ---"
    docker tag ${APP_NAME}:latest ${REGION}/${TENANCY_HASH}/${ENV}${APP_NAME}:latest

    echo "--- push image ${APP_NAME}:latest ---"
    docker push ${REGION}/${TENANCY_HASH}/${ENV}${APP_NAME}:latest

    echo "--- all set! ---"
  fi

fi