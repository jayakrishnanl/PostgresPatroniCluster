### OCI Creds for Terraform

## Update the values with your's

export TF_VAR_tenancy_ocid=
export TF_VAR_user_ocid=
export TF_VAR_compartment_ocid=

### OCI API keys
export TF_VAR_private_key_path=/
export TF_VAR_fingerprint=

### Region and Availability Domain
export TF_VAR_region=
export TF_VAR_availability_domain=1

### Public/Private keys used on the instance
### Replace with your key paths
export TF_VAR_ssh_public_key=$(cat /path/to/pubKey)
export TF_VAR_ssh_private_key=$(cat /path/to/privatekey)

