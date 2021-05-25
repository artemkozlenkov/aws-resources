#!/bin/bash -e 

ssh -A -i ~/.ssh/aws_private.pub -J ubuntu@"$1" ubuntu@"$2"
