variable "is_sensitive" {
  type = bool
}

variable "has_public_ip" {
  type    = bool
  default = true
}

variable "instance_type_master" {
  type    = string
  default = "t3.xlarge"
}

variable "instance_type_worker" {
  type    = string
  default = "t3.xlarge"
}

variable "owner_tag" {
  type = string
}

variable "create_new_aws_vpc" {
  type    = bool
  default = true
}

variable "cluster_workload" {
  type    = string
  default = ""
}

variable "ssh_public_key" {
  type = string
}

variable "aws_existing_vpc_id" {
  type    = string
  default = ""
}

variable "f5xc_cluster_labels" {
  type = map(string)
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_api_ca_cert" {
  type    = string
  default = ""
}

variable "f5xc_api_token" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

variable "f5xc_registration_wait_time" {
  type    = number
  default = 60
}

variable "f5xc_registration_retry" {
  type    = number
  default = 20
}

variable "f5xc_aws_region" {
  type = string
}

variable "f5xc_cluster_name" {
  type = string
}

variable "aws_vpc_cidr_block" {
  type    = string
  default = ""
}

variable "master_nodes_count" {
  type = number
  default = 3
}

variable "worker_nodes_count" {
  type = number
  default = 0
}

variable "vpc_subnets" {
  type = set(object({
    availability_zone = string
    cidr_block        = string
  }))
}

variable "f5xc_ce_machine_image" {
  type = object({
    voltstack = object({
      af-south-1     = string
      ap-east-1      = string
      ap-northeast-1 = string
      ap-northeast-2 = string
      ap-northeast-3 = string
      ap-south-1     = string
      ap-southeast-1 = string
      ap-southeast-2 = string
      ap-southeast-3 = string
      ca-central-1   = string
      eu-central-1   = string
      eu-north-1     = string
      eu-south-1     = string
      eu-west-1      = string
      eu-west-2      = string
      eu-west-3      = string
      me-south-1     = string
      sa-east-1      = string
      us-east-1      = string
      us-east-2      = string
      us-west-1      = string
      us-west-2      = string
    })
  })
  default = {
    voltstack = {
      af-south-1     = "ami-055ba977ad1ac6c6c"
      ap-east-1      = "ami-05673740d6f3baee9"
      ap-northeast-1 = "ami-030863f8dfd7029f5"
      ap-northeast-2 = "ami-001dd539455cd4038"
      ap-northeast-3 = ""
      ap-south-1     = "ami-00788bd38d0fa4ff0"
      ap-southeast-1 = "ami-0615e371749491e5f"
      ap-southeast-2 = "ami-0538af7edde340eb1"
      ap-southeast-3 = "ami-0f0c6b2822abb73e2"
      ca-central-1   = "ami-0e1d39ac2c1c6ef2b"
      eu-central-1   = "ami-094c24e0ff9141647"
      eu-north-1     = "ami-0e939f8711e36b456"
      eu-south-1     = "ami-0648b746bb1341bf4"
      eu-west-1      = "ami-01ef385d886b812d2"
      eu-west-2      = "ami-041138a60e1cb4314"
      eu-west-3      = "ami-0e576d6275f207196"
      me-south-1     = "ami-06603c1772bd574c2"
      sa-east-1      = "ami-082f0a654c0936aa5"
      us-east-1      = "ami-0f0926d6b6838b9cb"
      us-east-2      = "ami-0d011fcc6cae3ed0a"
      us-west-1      = "ami-0bec6c226bff67de2"
      us-west-2      = "ami-0d2f1966d883656cd"
    }
  }
}
