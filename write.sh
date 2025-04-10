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
---

apiVersion: v1
kind: Service
metadata:
name: lksdiycc2025-fe-service
spec:
selector:
    app: lksdiycc2025-fe-pod
ports:
- port: 80
  targetPort: 80

--- 

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
name: lksdiycc2025-fe-ingress
labels:
    name: lksdiycc2025-fe-ingress
annotations:
    alb.ingress.kubernetes.io/load-balancer-name: lksdiy-fe
    alb.ingress.kubernetes.io/ip-address-type: ipv4
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/healthcheck-path: / 
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
    alb.ingress.kubernetes.io/healthcheck-port: traffic-port
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '15'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/healthy-threshold-count: '3'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '5'
    alb.ingress.kubernetes.io/success-codes: '200,201,202,204,301,302'
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'

spec:
ingressClassName: ingress-alb-class
rules:
- http:
    paths:
    - pathType: Prefix
      path: "/"
      backend:
        service:
          name: lksdiycc2025-fe-service
          port: 
            number: 80

--- 

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
name: lksdiycc2025-fe-autoscalling
spec:
scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: lksdiycc2025-fe-deployment
minReplicas: 2
maxReplicas: 4
metrics:
- type: Resource
  resource:
    name: cpu
    target:
        type: Utilization
        averageUtilization: 70
" >> newdeployment.yaml

kubectl apply -f newdeployment.yaml
rm newdeployment.yaml
echo "Deployment, Service, Ingress and HPA created successfully."
echo "Please check the status of the deployment using the following command:"