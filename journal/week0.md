# Terraform Beginner Bootcamp 2023 - Week 0 

<!-- TOC -->

- [Terraform Beginner Bootcamp 2023 - Week 0](#terraform-beginner-bootcamp-2023---week-0)
    - [Semantic Versioning](#semantic-versioning)
    - [Install the Terraform CLI](#install-the-terraform-cli)
        - [Considerations with the Terraform CLI changes](#considerations-with-the-terraform-cli-changes)
        - [Considerations for Linux Distribution](#considerations-for-linux-distribution)
        - [Refactoring into Bash Scripts](#refactoring-into-bash-scripts)
            - [Shebang Considerations](#shebang-considerations)
            - [Execution Considerations](#execution-considerations)
            - [Linux Permissions Considerations](#linux-permissions-considerations)
        - [Github Lifecycle Before, Init, Command](#github-lifecycle-before-init-command)
        - [Working Env Vars](#working-env-vars)
            - [env command](#env-command)
            - [Setting and Unsetting Env Vars](#setting-and-unsetting-env-vars)
            - [Printing Vars](#printing-vars)
            - [Scoping of Env Vars](#scoping-of-env-vars)
            - [Persisting Env Vars in Gitpod](#persisting-env-vars-in-gitpod)
        - [AWS CLI Installation](#aws-cli-installation)
    - [Terraform Basics](#terraform-basics)
        - [Terraform Registry](#terraform-registry)
        - [Terraform Console](#terraform-console)
            - [Terraform Init](#terraform-init)
            - [Terraform Plan](#terraform-plan)
            - [Terraform Apply](#terraform-apply)
        - [Terraform Lock Files](#terraform-lock-files)
        - [Terraform State Files](#terraform-state-files)
        - [Terraform Directory](#terraform-directory)
        - [Terraform pricing](#terraform-pricing)
- [Terraform Workspace and Project](#terraform-workspace-and-project)
    - [Terraform Workspace](#terraform-workspace)
        - [Example:](#example)
    - [Authentication Methods](#authentication-methods)
        - [Token Requirements](#token-requirements)
        - [Set alias for Terraform in bash](#set-alias-for-terraform-in-bash)
- [Setting an Alias for Terraform in Bash](#setting-an-alias-for-terraform-in-bash)

<!-- /TOC -->


## Semantic Versioning

This project is going to utilize semantic versioning for its tagging.
[semver.org](https://semver.org/)


The general format:

**MAJOR.MINOR.PATCH**, eg. ` 1.0.1`


- **MAJOR** version when you make incompatible API changes
- **MINOR** version when you add functionality in a backward compatible manner
- **PATCH** version when you make backward compatible bug fixes

## Install the Terraform CLI

### Considerations with the Terraform CLI changes
The Terraform CLI installation instructions have changed due to gpg keyring changes. So we needed refer to the latest install CLI instructions via Terraform Documentation and change the scripting for install.

[Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


### Considerations for Linux Distribution

This project is built against Ubuntu.
Please consider checking your Linux Distrubtion and change accordingly to distrubtion needs. 

[How To Check OS Version in Linux](
https://www.cyberciti.biz/faq/how-to-check-os-version-in-linux-command-line/)

Example of checking OS Version:

```
$ cat /etc/os-release
PRETTY_NAME="Ubuntu 22.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
```

### Refactoring into Bash Scripts

While fixing the Terraform CLI gpg depreciation issues we notice that bash scripts steps were a considerable amount more code. So we decided to create a bash script to install the Terraform CLI.

This bash script is located here: [./bin/install_terraform_cli](./bin/install_terraform_cli)

- This will keep the Gitpod Task File ([.gitpod.yml](.gitpod.yml)) tidy.
- This allow us an easier to debug and execute manually Terraform CLI install
- This will allow better portablity for other projects that need to install Terraform CLI.

#### Shebang Considerations

A Shebang (prounced Sha-bang) tells the bash script what program that will interpet the script. eg. `#!/bin/bash`

ChatGPT recommended this format for bash: `#!/usr/bin/env bash`

- for portability for different OS distributions 
-  will search the user's PATH for the bash executable

https://en.wikipedia.org/wiki/Shebang_(Unix)

#### Execution Considerations

When executing the bash script we can use the `./` shorthand notiation to execute the bash script.

eg. `./bin/install_terraform_cli`

If we are using a script in .gitpod.yml  we need to point the script to a program to interpert it.

eg. `source ./bin/install_terraform_cli`

#### Linux Permissions Considerations

In order to make our bash scripts executable we need to change linux permission for the fix to be exetuable at the user mode.

```sh
chmod u+x ./bin/install_terraform_cli
```

alternatively:

```sh
chmod 744 ./bin/install_terraform_cli
```

https://en.wikipedia.org/wiki/Chmod

### Github Lifecycle (Before, Init, Command)

We need to be careful when using the Init because it will not rerun if we restart an existing workspace.

https://www.gitpod.io/docs/configure/workspaces/tasks


### Working Env Vars

#### env command

We can list out all Enviroment Variables (Env Vars) using the `env` command

We can filter specific env vars using grep eg. `env | grep AWS_`

#### Setting and Unsetting Env Vars

In the terminal we can set using `export HELLO='world`

In the terrminal we unset using `unset HELLO`

We can set an env var temporarily when just running a command

```sh
HELLO='world' ./bin/print_message
```
Within a bash script we can set env without writing export eg.

```sh
#!/usr/bin/env bash

HELLO='world'

echo $HELLO
```

#### Printing Vars

We can print an env var using echo eg. `echo $HELLO`

#### Scoping of Env Vars

When you open up new bash terminals in VSCode it will not be aware of env vars that you have set in another window.

If you want to Env Vars to persist across all future bash terminals that are open you need to set env vars in your bash profile. eg. `.bash_profile`

#### Persisting Env Vars in Gitpod

We can persist env vars into gitpod by storing them in Gitpod Secrets Storage.

```
gp env HELLO='world'
```

All future workspaces launched will set the env vars for all bash terminals opened in thoes workspaces.

You can also set en vars in the `.gitpod.yml` but this can only contain non-senstive env vars.

### AWS CLI Installation

AWS CLI is installed for the project via the bash script [`./bin/install_aws_cli`](./bin/install_aws_cli)


[Getting Started Install (AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
[AWS CLI Env Vars](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)

We can check if our AWS credentials is configured correctly by running the following AWS CLI command:
```sh
aws sts get-caller-identity
```

If it is succesful you should see a json payload return that looks like this:

```json
{
    "UserId": "RGTYVUO15ZPVHJ5WIJ8UK",
    "Account": "675456789543",
    "Arn": "arn:aws:iam::675456789543:user/terraform-beginner-bootcamp"
}
```
We will need to generate AWS CLI credits from IAM User in order to the user AWS CLI.

## Terraform Basics 

### Terraform Registry

Terraform sources their providers and modules from the Terraform registry which located at [registry.terraform.io](https://registry.terraform.io/)

- **Providers** is an interface to APIs that will allow to create resources in terraform.
- **Modules** are a way to make large amount of terraform code modular, portable and sharable.

[Randon Terraform Provider](https://registry.terraform.io/providers/hashicorp/random)

### Terraform Console

We can see a list of all the Terrform commands by simply typing `terraform`


#### Terraform Init

At the start of a new terraform project we will run `terraform init` to download the binaries for the terraform providers that we'll use in this project.

#### Terraform Plan

`terraform plan`

This will generate out a changeset, about the state of our infrastructure and what will be changed.

We can output this changeset ie. "plan" to be passed to an apply, but often you can just ignore outputting.

#### Terraform Apply

`terraform apply`

This will run a plan and pass the changeset to be execute by terraform. Apply should prompt yes or no.

If we want to automatically approve an apply we can provide the auto approve flag eg. `terraform apply --auto-approve`

### Terraform Lock Files

`.terraform.lock.hcl` contains the locked versioning for the providers or modulues that should be used with this project.

The Terraform Lock File **should be committed** to your Version Control System (VSC) eg. Github

### Terraform State Files

`.terraform.tfstate` contain information about the current state of your infrastructure.

This file **should not be commited** to your VCS.

This file can contain sensentive data.

If you lose this file, you lose knowning the state of your infrastructure.

`.terraform.tfstate.backup` is the previous state file state.

### Terraform Directory

`.terraform` directory contains binaries of terraform providers.

```hcl
# Specify the required providers and their versions
# The 'random' provider version 3.5.1 and the 'aws' provider version 5.16.2 are required.
required_providers {
  random = {
    source  = "hashicorp/random"
    version = "3.5.1"
  }
  aws = {
    source  = "hashicorp/aws"
    version = "5.16.2"
  }
}

# Configure the AWS provider
provider "aws" {
  # You can specify AWS credentials and region here if needed.
  # Example:
  # access_key = "YOUR_ACCESS_KEY"
  # secret_key = "YOUR_SECRET_KEY"
  # region     = "us-west-2"
}

# Configure the random provider (No specific configuration options in this example)
provider "random" {
  # Configuration options can be specified here if needed.
}

# Generate a random string for the S3 bucket name
# Reference: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "bucket_name" {
  lower   = true
  upper   = false
  length  = 32
  special = false
}

# Create an AWS S3 bucket with the random bucket name
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "example" {
  # Bucket Naming Rules:
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html?icmpid=docs_amazons3_console
  bucket = random_string.bucket_name.result
}

# Define an output to display the randomly generated bucket name
output "random_bucket_name" {
  value = random_string.bucket_name.result
}


## Terraform Cloud Login and Gitpod Workspace

Generate a token in Terraform Cloud

```
https://app.terraform.io/app/settings/tokens?source=terraform-login
```

Then create open the file manually here:

```sh
touch /home/gitpod/.terraform.d/credentials.tfrc.json
open /home/gitpod/.terraform.d/credentials.tfrc.json
```

Provide the following code (replace your token in the file):

```json
{
  "credentials": {
    "app.terraform.io": {
      "token": "YOUR-TERRAFORM-CLOUD-TOKEN"
    }
  }
}
``````

### Terraform pricing

```
https://www.hashicorp.com/products/terraform/pricing

```

# Terraform Workspace and Project

## Terraform Workspace

- A workspace in Terraform is a way to organize and isolate different configurations or environments for your infrastructure.
- Workspaces allow you to have multiple sets of Terraform configuration files within the same project directory, each representing a different environment (e.g., development, staging, production).
- Each workspace has its own set of variable values and state, which means you can have different infrastructure resources deployed for each workspace.
- You can create, switch between, and delete workspaces using Terraform commands like `terraform workspace new`, `terraform workspace select`, and `terraform workspace delete`.

### Example:

```bash
# Create a new workspace named "dev"
terraform workspace new dev

# Switch to the "dev" workspace
terraform workspace select dev

# Deploy infrastructure for the "dev" workspace
terraform apply

Project 📦
In a broader software development context, a "project" typically refers to a specific piece of work with defined objectives, scope, and resources.
A project may encompass multiple components, including code repositories, documentation, infrastructure configurations, and more.
Terraform is often used as a tool within a project to manage the infrastructure aspects of that project. 🚀
Example:
You might have a software development project that includes code repositories for application code, a Terraform project for provisioning infrastructure on a cloud provider, and perhaps a separate project for documentation.
Feel free to use this Markdown file in your GitHub repository or documentation, and the emojis will be correctly displayed.


We have automated this workaround with the following bash script bin/generate_tfrc_credentials

# Credentials for Terraform Cloud and Terraform Enterprise

Terraform Cloud provides a number of remote network services for use with Terraform, and Terraform Enterprise allows hosting those services inside your own infrastructure. For example, these systems offer both remote operations and a private module registry.

## API Tokens in CLI Configuration

When interacting with Terraform-specific network services, Terraform expects to find API tokens in CLI configuration files in credentials blocks. You can have multiple credentials blocks if you regularly use services from multiple hosts. Many users will configure only one, for either Terraform Cloud or their organization''s own Terraform Enterprise host. Each credentials block contains a token argument giving the API token to use for that host.

```hcl
credentials "app.terraform.io" {
  token = "xxxxxx.atlasv1.zzzzzzzzzzzzz"
}
```

## Authentication Methods

There are two primary authentication methods for obtaining API tokens:

1. **Interactive Authentication**: If you are running the Terraform CLI interactively on a computer with a web browser, you can use the `terraform login` command to get credentials. This command will initiate an interactive authentication flow, usually through a web page, and automatically save the obtained credentials in the CLI configuration.

2. **Manual Configuration**: If you are not running Terraform interactively or prefer manual configuration, you can manually write the credentials block in the CLI configuration file as shown above.

### Token Requirements

**Important**: If you are using Terraform Cloud or Terraform Enterprise, the token provided must be either a user token or a team token; organization tokens cannot be used for command-line Terraform actions.


### Set alias for Terraform in bash
```sh
open ~/.bash_profile 
source ~/.bash_profile (to apply changes)
```

# Setting an Alias for Terraform in Bash

To make using Terraform more convenient in your Bash shell, you can set up an alias. An alias allows you to create a custom shorthand command for running Terraform commands. Here's how to do it:

```bash
# Open a terminal.
# Use a text editor to edit your Bash configuration file, typically ~/.bashrc or ~/.bash_profile.
# Add the alias at the end of the file:
alias tf='terraform'
# Save and exit the text editor.
# To apply the changes, either restart your terminal or run:
source ~/.bashrc  # Use ~/.bash_profile if applicable.
# You can now use the 'tf' alias to run Terraform commands, e.g., 'tf init', 'tf plan', 'tf apply'.
```

The alias will make it more convenient to use Terraform commands in your terminal. You can replace 'tf' with any alias name you prefer.

![terraform login](https://github.com/ajmalrasouli/terraform-beginner-bootcamp-2023/assets/88502375/db089975-e2e4-42ab-a7c9-15efee100ccd)

![terra-house-1](https://github.com/ajmalrasouli/terraform-beginner-bootcamp-2023/assets/88502375/eeb92598-6388-4711-b80a-1155afaaca26)

![terraform init](https://github.com/ajmalrasouli/terraform-beginner-bootcamp-2023/assets/88502375/70fd28ba-a087-4b98-96e2-be1031eaa6e8)

![terraform S3](https://github.com/ajmalrasouli/terraform-beginner-bootcamp-2023/assets/88502375/94bcaf51-4997-447d-9e42-43d636a036f2)

![terraform S3 Destroy](https://github.com/ajmalrasouli/terraform-beginner-bootcamp-2023/assets/88502375/f02b587b-f4e9-4623-83ce-faae0e10942a)

![s3 static website](https://github.com/ajmalrasouli/terraform-beginner-bootcamp-2023/assets/88502375/00915da8-168f-4839-8b8f-581c576400c1)

![Static website](https://github.com/ajmalrasouli/terraform-beginner-bootcamp-2023/assets/88502375/8ef80a58-217d-4061-92e7-0e7621f17ef0)










