#!/bin/bash
terraform output -json appstack | jq -r '.appstack.master[],.appstack.worker[] | { private_ip: .private_ip, public_ip: .public_ip, private_dns: .private_dns }'
