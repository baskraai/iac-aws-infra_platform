# IaC AWS <name>
The configuration for the <name> component of the Infra-as-Code stack.

## Local development
For local development you need to add the file `backend.tf`:

```
terraform {
  backend "remote" {
    organization = "<org_name>"
    workspaces {
      name = "<workspace_name>"
    }
  }
}
```
