#!/bin/bash
set -e

export AWS_HOME=$RUNNER_TEMP/.aws
export AWS_CONFIG_FILE=$RUNNER_TEMP/.aws/config
export AWS_SHARED_CREDENTIALS_FILE=$RUNNER_TEMP/.aws/credentials
export AWS_REGION=$1
export AWS_ACCESS_KEY_ID=$2
export AWS_SECRET_ACCESS_KEY=$3
export ECR_REGISTRY=$4
export ECR_REPOSITORY=$5
export IMAGE_TAG=$6
export KUBE_CONFIG=$7

# Set the PATH to include our binaries
mkdir -p "${HOME}/.local/bin"
export PATH="${HOME}/.local/bin:${PATH}"
echo "::set-env name=PATH,::${PATH}"

# Configure AWS
mkdir -p "${AWS_HOME}"
echo "::set-env name=AWS_CONFIG_FILE,::${AWS_CONFIG_FILE}"
echo "::set-env name=AWS_SHARED_CREDENTIALS_FILE,::${AWS_SHARED_CREDENTIALS_FILE}"
aws configure set default.region $AWS_REGION
aws configure set default.output json
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

# Validate AWS credentials
aws sts get-caller-identity
#Build, tag, and push image to Amazon ECR
# Login to AWS ECR
$( aws ecr get-login-password --region $AWS_REGION )
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
#Setup Kube Context
export KUBECONFIG=$RUNNER_TEMP/.kube/config
# Setup AWS IAM Authenticator for Kubernetes
cd $( mktemp -d )
curl -o aws-iam-authenticator --location https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mv ./aws-iam-authenticator "${HOME}/.local/bin"
aws-iam-authenticator help
# Setup kustomize
cd $( mktemp -d )
curl -o kustomize --location https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64
chmod u+x ./kustomize
mv ./kustomize "${HOME}/.local/bin"
# Setup Kube Config
mkdir -p "${RUNNER_TEMP}/.kube"
echo "::set-env name=KUBECONFIG,::${KUBECONFIG}"
echo "${KUBE_CONFIG_DATA}" | base64 --decode > "${KUBECONFIG}"