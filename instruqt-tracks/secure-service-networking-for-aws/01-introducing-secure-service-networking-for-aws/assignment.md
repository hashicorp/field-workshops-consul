---
slug: introducing-secure-service-networking-for-aws
id: pmdwnnimxkfb
type: challenge
title: Introducing Secure Service Networking for AWS
teaser: Secure Service Networking is tricky on just one platform. Lets look at how
  we're going to secure all services acorss multiple platforms.
notes:
- type: text
  contents: Secure Service Networking is tricky on just one platform. Lets look at
    how we're going to secure all services acorss multiple platforms.
tabs:
- title: Shell
  type: terminal
  hostname: shell
difficulty: basic
timelimit: 600
---
In this Instruqt challenge we are going to:

1. create an HCP (HashiCorp Cloud Platform) account
2. verify HCP our auth credentials with terrafrom


1) Create an HCP Account
===

First navigate to the *HCP Consul* tab - this will open a new window.

1. Click the 'Sign Up' button.

2. In the left panel, navigate to "Access control (IAM)"

3. Scroll down to "Service Principals"

4. Click "Create service principal".

5. Give the service principal a name, e.g. 'aws-workshop'

6. Leave the Role as 'Contributor' and click 'Save'

7. Copy the 'Client ID' and the 'Client Secret' somewhere locally as you will need them soon.


2) Configure the Terraform HCP provider
===
1. In your Instrqut `shell` tab, create environment variables for the client id and client secret produced above, using the following commands:

    ```sh
    export HCP_CLIENT_ID=<your-hcp-client-id>
    ```

    ```sh
    export HCP_CLIENT_SECRET=<your-hcp-client-secret>
    ```

2. Test if these credentials work by executing `terraform plan` in the Instruqt `shell` tab

    If there is something wrong with the credentials you will receive an authentication error. Verify your credentials and re-export them. If you still enconter authentication issues try recreating the service principal from the previous step and copying the new id and secret.

    If everything worked you will see a wall of text describing the resources terraform is ready to provision for you. You are ready to proceed.


3. Variables are not preserved across Instrqut challenges. Either you can re-`export` them as variables (as above) when needed, or you can write them to a `terraform.tfvars` file with the following commands:

    ```sh
    echo "export HCP_CLIENT_ID=$HCP_CLIENT_ID" >> ~/.bashrc
    echo "export HCP_CLIENT_SECRET=$HCP_CLIENT_SECRET" >> ~/.bashrc
    ```

> **NOTE:** this lab environment is not shared and is automatically destroyed when finished. To ensure your HCP account remains secure you should consider deleting the service principal you created above when you have finished this workshop. You can create new service principal for further testing/experimentation. Read more about HCP Auth here: https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/guides/auth#two-options-to-configure-the-provider