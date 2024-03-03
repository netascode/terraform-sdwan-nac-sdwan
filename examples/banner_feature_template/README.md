<!-- BEGIN_TF_DOCS -->
# SDWAN Banner Feature Template Example
To run this example you need to execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

#### `banner_feature_template.yaml`

```yaml
sdwan:
  edge_feature_templates:
    banner_templates:
      - name: FT-CEDGE-BANNER-01
        description: Base banner template; support carrier returns
        login: "login banner: new\n"
        motd: "motd banner:\r\nNo message today\n"
```

#### `main.tf`

```hcl
module "sdwan" {
  source  = "netascode/nac-sdwan/sdwan"
  version = "0.1.0"

  yaml_files = ["banner_feature_template.yaml"]
}
```
<!-- END_TF_DOCS -->