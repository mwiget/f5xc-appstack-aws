# f5xc-appstack-aws

Experimental deployment of 3-node Appstack site in AWS plus worker nodes.

Clone this repo with `Clone this repo with: git clone --recurse-submodules https://github.com/mwiget/f5xc-appstack-aws`

Copy terraform.tfvars.example to terraform.tfvars, then update the file with credentials 
and number of desired master (1 or 3) and worker nodes (0..128).

```
terraform init
terraform plan
terraform apply
```

Verify cluster with

```
$ ./cluster_info.sh

Kubernetes control plane is running at https://volterra-corp.staging.volterra.us/api/k8s/namespaces/system/site/marcel-aws1

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

NAME                                           STATUS   ROLES        AGE    VERSION
ip-192-168-1-150.eu-north-1.compute.internal   Ready    ves-master   140m   v1.23.14-ves
ip-192-168-1-224.eu-north-1.compute.internal   Ready    <none>       125m   v1.23.14-ves
ip-192-168-2-215.eu-north-1.compute.internal   Ready    ves-master   141m   v1.23.14-ves
ip-192-168-2-245.eu-north-1.compute.internal   Ready    <none>       125m   v1.23.14-ves
ip-192-168-3-196.eu-north-1.compute.internal   Ready    ves-master   141m   v1.23.14-ves
```
