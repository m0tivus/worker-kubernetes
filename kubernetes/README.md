# Steps followed: 

0. Generate ocir secret

```shell

kubectl create secret docker-registry ocirsecret --docker-server=sa-saopaulo-1.ocir.io --docker-username='YOUR_TENANCY_HASH/service_user' --docker-password='YOUR_OCIR_TOKEN' --namespace workers

```

1. Generate Namespace

```shell
$ kubectl create namespace workers
namespace/workers created
```

2. Deploy metrics server:

```shell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability.yam
```

3. To create HPA via Kubectl: 

```shell
kubectl autoscale deployment wb-worker-deployment --cpu-percent=70 --min=1 --max=5 --namespace workers
horizontalpodautoscaler.autoscaling/wb-worker-deployment autoscaled
```
