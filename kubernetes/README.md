# Steps followed: 


0. Generate Namespace

```shell
$ kubectl create namespace workers
namespace/workers created
```

1. Generate ocir secret

```shell
kubectl create secret docker-registry ocirsecret --docker-server=sa-santiago-1.ocir.io --docker-username='YOUR_TENANCY_HASH/service_user' --docker-password='YOUR_OCIR_TOKEN' --namespace workers
```

2. Deploy metrics server:

```shell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability.yaml
```

3. To create HPA via yaml file: 

```shell
kubectl apply -f 03_autoscaler.yaml 
horizontalpodautoscaler.autoscaling/wb-worker-hpa created
```