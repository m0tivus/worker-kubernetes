# Steps followed: 

0. Generate ocir secret

kubectl create secret docker-registry ocirsecret --docker-server=sa-saopaulo-1.ocir.io --docker-username='YOUR_TENANCY_HASH/service_user' --docker-password='YOUR_OCIR_TOKEN' --namespace workers

1. Generate Namespace

```shell
$ kubectl create namespace workers
namespace/workers created
```

2. 