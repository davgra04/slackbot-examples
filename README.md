slackbot-examples
=================

This repo contains a few examples of slackbots written in Python.

# Usage

## Spin up EC2 instance to host slackbot with Terraform

1. Generate new key to use in AWS
   ```bash
   ssh-keygen -t rsa -C this-is-my-server-key -f ~/.ssh/whatever.key
   ```
2. Configure Terraform vars file
   ```bash
   # deployment.tfvars
   my_ip = "8.8.8.8"                                   # IP to whitelist for SSH

   instance_type_lb = "t2.nano"                        # instance size for load balancer
   instance_type_db = "t2.nano"                        # instance size for database
   instance_type_app = "t2.nano"                       # instance size for application

   key_name = "this-is-my-server-key"                  # key name
   private_key_path = "~/.ssh/whatever.key"            # private key path
   public_key_path = "~/.ssh/whatever.key.pub"         # public key path
   ```
3. Spin up infrastructure with Terraform
   ```bash
   # init and launch using .tfvars file
   cd tf/
   terraform init
   terraform apply -var-file="deployment.tfvars" --auto-approve
   ```

## Register and Configure Slack App

1. Create new Slack app
   * https://api.slack.com/apps?new_app=1&ref=bolt_start_hub
   * give it a name
   * choose a workspace
2. Request scopes
   * https://api.slack.com/apps/
   * navigate to app > OAuth & Permissions > Bot Token Scopes
   * add relevant OAuth scopes
3. Install app to workspace
   * https://api.slack.com/apps/
   * navigate to app > Install App
   * click Install
     * this will require admin approval
4. Enable other features
   * things like the app home feature
5. Save tokens to creds.txt
   ```bash
   # creds.txt
   export SLACK_BOT_TOKEN=xoxb-your-oauth-token
   export SLACK_SIGNING_SECRET=your-apps-signing-secret
   ```

## Deploy Slackbot

1. Copy bot files to EC2 instance
2. Create virtual environment
    ```
    python3 -m venv ./env
    ```
3. Install required libraries
    ```
    pip install -r requirements.txt
    ```
4. Source app credentials
    ```
    source creds.txt
    ```
5. Run slackbot
    ```
    python examplebot.py
    ```
6. Subscribe to events API
   * https://api.slack.com/apps/
   * navigate to app > Event Subscriptions
   * enable events and add request URL (URL to server)
     * by default, bolt uses `/slack/events` route
   * subscribe to relevant events


