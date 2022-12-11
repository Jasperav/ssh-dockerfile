#!/bin/bash

set -e

echo "This will login into AWS + Docker, create a repository and push the image to ECR"
echo "If you got any trouble, check push_to_ecr.readme"
echo "Usage: --region <REGION> --aws-account-id <AWS_ACCOUNT_ID> --image-name <IMAGE_NAME> --repository-name <REPO_NAME>"

if [ $# -ne 8 ]
  then
    echo "Arguments are not correct"
    exit 1
fi

REGION=$2
AWS_ACCOUNT_ID=$4
IMAGE_NAME=$6
REPOSITORY_NAME=$8

echo "Region: $REGION";
echo "Account id: $AWS_ACCOUNT_ID";
echo "Image name: $IMAGE_NAME";
echo "Repo name: $REPOSITORY_NAME";
IMAGE_ID=$(docker images -q "$IMAGE_NAME")
ECR_LINK="$AWS_ACCOUNT_ID".dkr.ecr."$REGION".amazonaws.com
ECR_REPOSITORY=$ECR_LINK/$REPOSITORY_NAME
echo "Image id: $IMAGE_ID";

# Time to roll
# Actually everything is from https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR_LINK"

# Create the repository
aws ecr create-repository \
    --repository-name "$REPOSITORY_NAME" \
    --region "$REGION"

docker tag "$IMAGE_ID" "$ECR_REPOSITORY"
docker push "$ECR_REPOSITORY"