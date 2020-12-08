slackbot-examples
=================

This repo contains a few examples of slackbots written in Python.

# Usage

## Spin up EC2 instance to host slackbot with Terraform

1. Manually create Elastic IP
   * We want this to persist outside of Terraform so DNS config remains unchanged
2. Set up DNS routing
   * Configure the domain provider's DNS settings with an A Record pointing to the Elastic IP.
3. Generate new key to use in AWS
   ```bash
   ssh-keygen -t rsa -C this-is-my-server-key -f ~/.ssh/whatever.key
   ```
4. Configure Terraform vars file
   ```bash
   # deployment.tfvars

   eip_allocation_id = "eipalloc-d3adb33fd3adb33f"     # elastic ip to associate instance with
   my_ip = "8.8.8.8"                                   # IP to whitelist for SSH

   instance_type_lb = "t2.nano"                        # instance size for load balancer
   instance_type_db = "t2.nano"                        # instance size for database
   instance_type_app = "t2.nano"                       # instance size for application

   key_name = "this-is-my-server-key"                  # key name
   private_key_path = "~/.ssh/whatever.key"            # private key path
   public_key_path = "~/.ssh/whatever.key.pub"         # public key path
   ```
5. Spin up infrastructure with Terraform
   ```bash
   # Set the terraform workspace for the current deployment
   cd tf/
   terraform workspace select my-deployment

   # init and launch using .tfvars file
   terraform init
   terraform apply -var-file="deployment.tfvars" --auto-approve
   ```

## Deploy Slackbot


## Register and Configure Slack App



