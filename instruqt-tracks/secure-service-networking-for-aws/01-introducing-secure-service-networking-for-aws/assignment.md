---
slug: introducing-secure-service-networking-for-aws
type: challenge
title: Introducing Secure Service Networking for AWS
teaser: Before we create a managed Consul service on HCP we need to create an HCP
  account and a service principal.
notes:
- type: text
  contents: In this challenge you will create an HCP account and a service principal.
tabs:
- title: Infrastructure Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-infra-overview.html
- title: App Architecture Overview
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/secure-service-networking-for-aws/assets/images/ssn4aws-app-overview.html
- title: HCP Consul
  type: website
  url: https://portal.cloud.hashicorp.com:443/sign-up
  new_window: true
- title: code - HCP
  type: code
  hostname: shell
  path: /root/terraform/tf-verify-hcp-auth
- title: Cloud Consoles
  type: service
  hostname: shell
  path: /
  port: 80
- title: Shell
  type: terminal
  hostname: shell
difficulty: basic
timelimit: 2400
---
In this workshop you are going to use the HashiCorp Cloud Platform (HCP) to securely interconnect services within, and across, the AWS EKS and ECS platforms shown in the `Infrastructure Overview` tab.

Before we deploy a managed Consul service on HCP we need to create an HCP account and a service principal. We will use the Service Principals "Client ID" and "Client Secret" in the following Instruqt workshop challenges.

In this Instruqt challenge we are going to:

1. Create HashiCorp Cloud Platform (HCP) auth credentials
2. Verify your HCP auth credentials using terrafrom

NOTE: You can find video insructions via the document/notes icon in the top right corner of this web page.

Continue with the steps below:

1) Create HCP Auth Credentials
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

The HCP Terraform Provider will use these variables to connect to the HCP platform.


2. Test if these credentials work by executing the following command in the Instruqt `shell` tab:

   ```sh
   terraform apply -auto-approve
   ```

    If there is something wrong with the credentials you will receive an authentication error:

    **If the variables aren't set:**

    `Error: unable to create HCP api client: invalid config: client ID not provided`

    **If the Client ID or Client Secret are invalid:**

    `Error: unable to get project from credentials: unable to fetch organization list: Get "https://api.cloud.hashicorp.com/resource-manager/2019-12-10/organizations": oauth2: cannot fetch token: 401 Unauthorized`

    Verify your credentials and re-export them. If you still enconter authentication issues try recreating the service principal from the previous step and copying the new id and secret.

    If everything worked you will see terraform output showing a list of available consul versions on HCP You are ready to proceed.


3. Variables are not preserved across Instrqut workshop challenges. Either you can re-`export` them as variables (as above) when needed, you can write them to a `terraform.tfvars` file, or you can persist them throughout the workshop by writting them to your .bashrc file with the following commands:

    ```sh
    echo "export HCP_CLIENT_ID=$HCP_CLIENT_ID" >> ~/.bashrc
    echo "export HCP_CLIENT_SECRET=$HCP_CLIENT_SECRET" >> ~/.bashrc
    ```

> **NOTE:** this lab environment is not shared and is automatically destroyed when finished. To ensure your HCP account remains secure you should consider deleting the service principal's Client ID/Secret you created above when you have finished this workshop. You can create a new Client ID/Secret for further testing/experimentation at any time. Read more about HCP Auth here: https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/guides/auth#two-options-to-configure-the-provider
