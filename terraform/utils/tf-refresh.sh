# refresh example
TF_FORCE_LOCAL_BACKEND=1 terraform refresh -var 'aws_region=eu-central-1' -var 'fqdn=softawebit.com' -lock=false
