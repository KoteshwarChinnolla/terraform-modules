#!/bin/bash
set -e

AWS_REGION="${AWS_REGION:-ap-south-2}"
AWS_ACCOUNT="${AWS_ACCOUNT:-208940303379}"
REPO="${REPO:-$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/cafe}"
VERSION="${VERSION:-v1.0.2}"
ENV_FILE_PATH="${ENV_FILE_PATH:-$HOME/.env}"

echo "🚀 Deployment configuration:"
echo "  AWS_REGION    = $AWS_REGION"
echo "  AWS_ACCOUNT   = $AWS_ACCOUNT"
echo "  REPO          = $REPO"
echo "  VERSION       = $VERSION"
echo "  ENV_FILE_PATH = $ENV_FILE_PATH"
echo


echo "🔐 Logging into ECR"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com"


echo "🛑 Stopping existing container"
docker stop cafe || true
docker rm cafe || true


echo "🧹 Removing old images"
docker images "$REPO" -q | xargs -r docker rmi -f


echo "⬇️ Pulling latest image"
docker pull "$REPO:$VERSION"

echo "🚀 Starting new container"
docker run -d --name cafe --network host --env-file "$ENV_FILE_PATH" "$REPO:$VERSION"

echo "✅ Deployment complete"