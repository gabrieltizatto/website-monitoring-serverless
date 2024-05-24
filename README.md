## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.monitoring_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lambda_function.website_checker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | n/a | `string` | n/a | yes |
| <a name="input_monitoring_rate"></a> [monitoring\_rate](#input\_monitoring\_rate) | n/a | `string` | n/a | yes |
| <a name="input_recipient_email"></a> [recipient\_email](#input\_recipient\_email) | n/a | `string` | n/a | yes |
| <a name="input_sender_email"></a> [sender\_email](#input\_sender\_email) | n/a | `string` | n/a | yes |
| <a name="input_websites_urls"></a> [websites\_urls](#input\_websites\_urls) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
