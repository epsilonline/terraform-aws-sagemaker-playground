# Terraform SageMaker Module

This Terraform module creates and manages AWS SageMaker resources necessary to build a SageMaker domain in VPC-only mode with user profiles, private and shared spaces, and different app types within the spaces.

## Requirements

- Terraform >=1.4.0
- AWS Provider ~>5.82.2

## Features

- Create a VPC for the SageMaker Domain
- Create Security Group Rules to allow all outbound traffic
- Create Security Group Rules to allow inbound traffic from Jupyter Lab and Git (SSH)
- Create a SageMaker Domain
- Create Private and Shared Spaces inside the Domain
- Launch SageMaker Apps (such as Code Editor, Jupyter Notebooks, etc.) in the Spaces
- Create different SageMaker user profiles for Data Scientists and ML Engineers
- Possibility to use KMS encryption

## Usage

Import the module:

```hcl
module "sagemaker" {
  source = "gitlab.com/epsilonline/terraform-modules/terraform-aws-sagemaker-playground"
}
```

Run terraform:

```hcl
terraform init
terraform apply
```

## Inputs

### Shared Vars

| Name              | Description                                    | Type        |
|-------------------|------------------------------------------------|-------------|
| `aws_region`      | AWS Region                                     | `string`    |
| `environment`     | Application environment                        | `string`    |
| `application`     | Application name                               | `string`    |

### SageMaker Domain

| Name                       | Description                                     | Type        |
|----------------------------|-------------------------------------------------|-------------|
| `domain_name`              | SageMaker Domain Name                           | `string`    |
| `auth_mode`                | Authentication mode to access the domain       | `string`    |
| `allowed_instance_types`   | List of EC2 instance types users are allowed to launch | `list(string)` |
| `instance_type`            | Instance type for SageMaker Domain              | `string`    |
| `sagemaker_domain_execution_role` | Execution role for SageMaker Domain        | `string`    |
| `app_network_access_type`  | VPC used for non-EFS traffic                    | `string`    |
| `efs_retention_policy`     | Retention policy for data on an EFS volume      | `string`    |
| `enable_docker`            | Enables Local Mode and Docker Access           | `string`    |
| `canvas_use`               | Enables the creation of resources for SageMaker Canvas | `bool`     |
| `jupyter_image_tag`        | Jupyter Image Tag                               | `string`    |
| `sagemaker_image_arn_prefix` | SageMaker Image ARN prefix                    | `string`    |

### SageMaker Profiles

| Name                        | Description                                      | Type        |
|-----------------------------|--------------------------------------------------|-------------|
| `sm_settings`               | SageMaker profiles and Private Spaces to create for the domain | `map(object)` |

### SageMaker Shared Spaces

| Name                        | Description                                      | Type        |
|-----------------------------|--------------------------------------------------|-------------|
| `shared_spaces`             | Shared Spaces to create for the domain           | `map(object)` |

### Shut Down Script

| Name                        | Description                                      | Type        |
|-----------------------------|--------------------------------------------------|-------------|
| `auto_shutdown`             | Enables the creation of resources related to auto_shutdown script | `bool`     |

### KMS

| Name                        | Description                                      | Type        |
|-----------------------------|--------------------------------------------------|-------------|
| `kms_encryption`            | Enables the creation of encryption resources    | `bool`      |
| `kms_arn`                   | KMS key for EFS encryption                      | `string`    |

### VPC

| Name                        | Description                                      | Type        |
|-----------------------------|--------------------------------------------------|-------------|
| `cidr_block`                | CIDR block for SageMaker VPC                    | `string`    |
| `private_subnet_cidrs`      | Private Subnet CIDR values                      | `list(string)` |
| `public_subnet_cidrs`       | Public Subnet CIDR values                       | `list(string)` |
| `azs`                       | Availability Zones                               | `list(string)` |
| `enable_dns_support`        | Enables DNS Support                              | `bool`      |
| `enable_dns_hostnames`      | Enables DNS Hostnames                            | `bool`      |
| `enable_nat_gateway`        | Enables creation of Nat Gateway                  | `bool`      |
| `single_nat_gateway`        | Creates a single NGW                             | `bool`      |
| `one_ngw_per_az`            | Creates only one NGW per AZ                      | `bool`      |
| `enable_vpn_gateway`        | Enables creation of VPN Gateway                  | `bool`      |

## Variable `sm_settings` usage example

The `sm_settings` variable is used to define the SageMaker profiles and private spaces that you want to create within the SageMaker Domain, as well as associated spaces settings.

### Example Configuration

```hcl
  sm_settings = {
    "User1" = {
      role = "DataScientist"
      spaces = {
        "JupyterLabUser1" = {
          app_type        = "JupyterLab"
          app_name        = "JupyterLab"
          instance_type   = "ml.m5.large"
          image_arn       = "arn:aws:sagemaker:region:account-id:image/image-name"
          idle_timeout_in_minutes = null
        },
        "CodeEditorUser1" = {
          app_type        = "CodeEditor"
          app_name        = "default"
          instance_type   = "ml.c5.large"
          image_arn       = ""
        }
      }
    },
    "User2" = {
      role = "MLEngineer"
      spaces = {
        "CodeEditorUser2" = {
          app_type        = "CodeEditor"
          app_name        = "default"
          instance_type   = "ml.c5.xlarge"
          image_arn       = "arn:aws:sagemaker:region:account-id:image/image-name"
        }
      }
    }
  }
```

## Outputs

### SageMaker Domain

| Name                    | Description                                     |
|-------------------------|-------------------------------------------------|
| `sagemaker_domain_id`    | The value of SageMaker domain id                |
| `sagemaker_domain_arn`   | ARN of the SageMaker domain                     |

### SageMaker User Profiles

| Name                        | Description                                      |
|-----------------------------|--------------------------------------------------|
| `data_scientist_profile_ids`| ID of SageMaker profiles of Data Scientists      |
| `ml_engineer_profile_ids`   | ID of SageMaker profiles of ML Engineers         |

### SageMaker Spaces

| Name                       | Description                                      |
|----------------------------|--------------------------------------------------|
| `sagemaker_spaces_id`       | ID of the Spaces in the SageMaker Domain         |
| `sagemaker_spaces_arn`      | ARN of the Spaces in the SageMaker Domain        |

### IAM

| Name                    | Description                                     |
|-------------------------|-------------------------------------------------|
| `default_execution_role` | The execution role used for SageMaker Domain    |

### VPC

| Name                     | Description                                      |
|--------------------------|--------------------------------------------------|
| `vpc_id`                 | ID of the VPC                                    |
| `subnet_ids`             | IDs of the Subnets of the VPC                    |
| `security_group_id`      | IDs of the Security Groups in the VPC            |

## License

This project is licensed under the MIT License.
