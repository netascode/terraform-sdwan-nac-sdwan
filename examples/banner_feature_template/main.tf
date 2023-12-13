module "sdwan" {
  source  = "netascode/nac-sdwan/sdwan"
  version = "0.1.0"

  yaml_files = ["banner_feature_template.yaml"]
}
