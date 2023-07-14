# f5xc-appstack-aws

Experimental deployment of 3-node Appstack site in AWS plus worker nodes.

Clone this repo with `Clone this repo with: git clone --recurse-submodules https://github.com/mwiget/f5xc-appstack-aws`

Deploy in 2 steps, first the cluster nodes using 

```
terraform apply -target volterra_voltstack_site.cluster
```

followed by 

```
terraform apply
```

(The registration resource is created for every deployed node, which is only known after the cluster nodes have been deployed).

