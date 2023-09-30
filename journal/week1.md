# Terraform Beginner Bootcamp 2023 - Week 1

## Root Module Structure

Our root module structure is as follows:

```
PROJECT_ROOT
│
├── main.tf                 # everything else.
├── variables.tf            # stores the structure of input variables
├── terraform.tfvars        # the data of variables we want to load into our terraform project
├── providers.tf            # defined required providers and their configuration
├── outputs.tf              # stores our outputs
└── README.md               # required for root modules
```

[Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)

## Terraform and Input Variables

### Terraform Cloud Variables

In terraform we can set two kind of variables:
- Enviroment Variables - those you would set in your bash terminal eg. AWS credentials
- Terraform Variables - those that you would normally set in your tfvars file

We can set Terraform Cloud variables to be sensitive so they are not shown visibliy in the UI.

### Loading Terraform Input Variables

[Terraform Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)

### var flag
We can use the `-var` flag to set an input variable or override a variable in the tfvars file eg. `terraform -var user_ud="my-user_id"`

### var-file flag

- In Terraform, the var-file flag is used to specify a variable file that contains values for variables defined in your Terraform configuration. This flag is particularly useful when you want to separate your variable values from your main configuration file, making it easier to manage different configurations for different environments or to keep sensitive information, such as API keys or passwords, separate from your main code.

    By using the -var-file flag, you can easily switch between different sets of variable values for different environments (e.g., development, staging, production) without modifying your main configuration files. This makes it easier to manage your infrastructure as code and maintain a separation of concerns between configuration and variable values.

### terraform.tvfars

This is the default file to load in terraform variables in blunk

### auto.tfvars

- **In Terraform, `auto.tfvars`** is a special filename that Terraform automatically looks for when you run Terraform commands like `terraform apply` or `terraform plan`. This file allows you to define default values for variables without explicitly specifying them on the command line or in a separate variable file.

Here's how it works:

1. **Create `auto.tfvars`**: In your Terraform project directory, create a file named `auto.tfvars` (or `auto.tfvars.json` for JSON formatted variables) if it doesn't already exist.

2. **Define Variable Values**: Inside the `auto.tfvars` file, you can define default values for your variables. For example:

   ```hcl
   variable_name = "default_value"
   another_variable = 42


### order of terraform variables

- In Terraform, the order of variables typically doesn't matter because variables are declared and then used as needed throughout your Terraform configuration. However, there are some conventions and best practices you can follow for organizing and documenting your variables:

1. **Variable Declarations:** Variables are typically declared at the beginning of your Terraform configuration file(s). This is where you specify the variable name, type, and optional default value. Here's an example:

```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

```

2. **Resource Blocks:** Variables are often used within resource blocks, data blocks, or other configurations to parameterize your infrastructure. These resource blocks can be placed anywhere in your Terraform configuration file(s) as needed:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = var.instance_type
  subnet_id     = "subnet-12345678"
  tags = {
    Name = "example-instance"
  }
}
```


In Terraform, the order of variables typically doesn't matter because variables are declared and then used as needed throughout your Terraform configuration. However, there are some conventions and best practices you can follow for organizing and documenting your variables:

**Variable Declarations:** Variables are typically declared at the beginning of your Terraform configuration file(s). This is where you specify the variable name, type, and optional default value. Here's an example:

```hcl
Copy code
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
```

**Resource Blocks:** Variables are often used within resource blocks, data blocks, or other configurations to parameterize your infrastructure. These resource blocks can be placed anywhere in your Terraform configuration file(s) as needed:

```hcl
Copy code
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = var.instance_type
  subnet_id     = "subnet-12345678"
  tags = {
    Name = "example-instance"
  }
}
```

3. **Variable Values:** When you assign values to variables, you can do so in various ways:

- Using default values in the variable declarations.
- Using explicit variable values when running Terraform commands, either through command-line flags (`-var`) or a variable file (`-var-file`).
- Using interpolation to derive values based on other variables or data sources.
The order in which you assign variable values, whether through default values, explicit values, or interpolations, doesn't matter from a functional perspective. Terraform will resolve the variable values during its execution.

4. **Documentation:** It's a good practice to include comments or documentation for each variable declaration to explain its purpose, valid values, and any additional context. This helps make your configuration more understandable for both yourself and your team members:

```hcl
variable "instance_type" {
  type        = string
  description = "The EC2 instance type for the example instance."
  default     = "t2.micro"
}
```

5. **Consistency and Style:** While the order of variables doesn't affect Terraform's functionality, maintaining a consistent style and organization in your code can make it more readable and maintainable. You may want to group related variables together or follow a specific naming convention for your variables.