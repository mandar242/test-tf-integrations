# test-tf-integrations
Repository contains code used for testing various terraform collection, roles


## cloud.terraform_ops

### cloud.terraform_ops.aws_s3backend example
```
### setup_remote_backend_s3.yml

use `cloud.terraform_ops.aws_s3backend` to set up terraform remote backend in AWS S3 bucket.

cmd: `ansible-playbook setup_remote_backend_s3.yml`
```
### cloud.terraform_ops.plan_stash example
```
### plan_stash_role_*.yml
Note:
Below playbooks should be used in AWX/Cotroller/Tower.
To use
1. Create Job templates for both playbooks.
2. Create workflow template where playbook 1 runs, on success playbook 2 runs.

### plan_stash_role_stash.yml
use `cloud.terraform.plan_stash` to `stash` the terraform plan to ansible stats.

#### plan_stash_role_load.yml
use `cloud.terraform.plan_stash` to `load` terraform plan from ansible stats to a plan file.
```

## cloud.terraform

### cloud.terraform.terraform example
```
### apply_destroy_config.yml

use `cloud.terraform.terraform` module to apply and destory terraform configs.

cmd: `ansible-playbook apply_destroy_config.yml`
```

### cloud.terraform.terraform_state example
```
### ansible_tf_inventory.terraform_state.yml

use `cloud.terraform.terraform_state` plugin to generate dynamic inventory from plan file.

cmd: `ansible-inventory -i ansible_tf_inventory.terraform_state.yml --graph --vars`
```

### cloud.terraform.plan_stash examples
```
### plan_stash_module_*.yml
Note:
Below playbooks should be used in AWX/Cotroller/Tower.
To use
1. Create Job templates for both playbooks.
2. Create workflow template where playbook 1 runs, on success playbook 2 runs.

#### plan_stash_module_stash.yml

use `cloud.terraform.plan_stash` to `stash` the terraform plan to ansible stats.

#### plan_stash_module_load.yml

use `cloud.terraform.plan_stash` to `load` terraform plan from ansible stats to a plan file.
```

## terraform-provider-ansible
```
### tf-ansible-provider/tf-provider-ansible.tf

Terraform config file to
1. create EC2 instance with required infrastructure to enable ssh
2. Use `Ansible Provider for Terraform` to add created EC2 instance to host groups using `ansible_host` and run playbooks on it using `ansible-playbook`
Note: Before running change value of `aws_instance.mk-provider-test_ec2.key_name` to name of key stored in aws.

`tf init`, `tf plan`, `tf apply --auto-approve`
```

### Other files in repo
```
### rand_string.tf
Terraform config file to generate random string.

### tf-aws-gcp-instance/main.tf
Terraform config file to create instance/vm in AWS and GCP.

### tf-ansible-provider/simple-playbook.yml
Simple playbook that creates a file and write content to it.

### tf-ansible-provider/updated-simple-playbook.yml
Simple playbook that creates a file and write content to it.
```
