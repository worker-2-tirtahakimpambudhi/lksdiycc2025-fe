#/bin/bash

ECR_REGISTRY="$1"
REPOSITORY_NAME="$2"
IMAGE_TAG="$3"

ECR_REGISTRY=${ECR_REGISTRY}
REPOSITORY_NAME=${REPOSITORY_NAME}
IMAGE_TAG=${IMAGE_TAG}

echo "
apiVersion: apps/v1
kind: Deployment
metadata:
name: lksdiycc2025-fe-deployment
spec:
selector:
    matchLabels:
    app: lksdiycc2025-fe-pod
template:
    metadata:
    labels:
        app: lksdiycc2025-fe-pod
    spec:
    containers:
    -   name: lksdiycc2025-fe-container
        image: $ECR_REGISTRY/$REPOSITORY_NAME:$IMAGE_TAG
        resources:
        limits:
            memory: "128Mi"
            cpu: "100m"
        ports:
        - containerPort: 80
" >> newdeployment.yaml

kubectl apply -f newdeployment.yaml
rm newdeployment.yaml
echo "Deployment, Service, Ingress and HPA created successfully."
echo "Please check the status of the deployment using the following command:"