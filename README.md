# test-tf-integrations
Repository contains code used for testing various terraform collection, roles


## cloud.terraform_ops
### setup_remote_backend_s3.yml

`cloud.terraform_ops.aws_s3backend` to set up terraform remote backend in AWS S3 bucket.
`ansible-playbook setup_remote_backend_s3.yml`

### plan_stash_role_*.yml
Note:
Below playbooks should be used in AWX/Cotroller/Tower.
To use
1. Create Job templates for both playbooks.
2. Create workflow template where playbook 1 runs, on success playbook 2 runs.

#### plan_stash_role_stash.yml

`cloud.terraform.plan_stash` to `stash` the terraform plan to ansible stats.
`ansible-playbook plan_stash_role_stash.yml`

#### plan_stash_role_load.yml

`cloud.terraform.plan_stash` to `load` terraform plan from ansible stats to a plan file.
`ansible-playbook plan_stash_role_load.yml`


## cloud.terraform
### apply_destroy_config.yml

`cloud.terraform.terraform` module to apply and destory terraform configs.
`ansible-playbook apply_destroy_config.yml`

### ansible_tf_inventory.terraform_state.yml

`cloud.terraform.terraform_state` plugin to generate dynamic inventory from plan file.
`ansible-inventory -i ansible_tf_inventory.terraform_state.yml --graph --vars`


### plan_stash_module_*.yml
Note:
Below playbooks should be used in AWX/Cotroller/Tower.
To use
1. Create Job templates for both playbooks.
2. Create workflow template where playbook 1 runs, on success playbook 2 runs.

#### plan_stash_module_stash.yml

`cloud.terraform.plan_stash` to `stash` the terraform plan to ansible stats.
`ansible-playbook plan_stash_module_stash.yml`

#### plan_stash_module_load.yml

`cloud.terraform.plan_stash` to `load` terraform plan from ansible stats to a plan file.
`ansible-playbook plan_stash_module_load.yml`


### rand_string.tf
Terraform config file to generate random string.

### tf-aws-gcp-instance/main.tf
Terraform config file to create instance/vm in AWS and GCP.

### tf-ansible-provider/tf-provider-ansible.tf
Terraform config file to 
1. create EC2 instance with required infrastructure to enable ssh
2. Use `Ansible Provider for Terraform` to add created EC2 instance to host groups using `ansible_host` and run playbooks on it using `ansible-playbook`
Note: Before running change value of `aws_instance.mk-provider-test_ec2.key_name` to name of key stored in aws.
