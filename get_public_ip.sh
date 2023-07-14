#!/bin/bash
terraform output -json |gron|grep \.public_ip\ |grep value
