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

