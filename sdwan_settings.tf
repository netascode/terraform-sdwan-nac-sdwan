
resource "sdwan_cloud_provider_settings" "cloud_provider_settings" {
  count                     = try(local.settings.cloud_provider_settings, null) != null ? 1 : 0
  umbrella_org_id           = try(local.settings.cloud_provider_settings.umbrella_org_id, null)
  umbrella_auth_key_v2      = try(local.settings.cloud_provider_settings.umbrella_auth_key_v2, null)
  umbrella_auth_secret_v2   = try(local.settings.cloud_provider_settings.umbrella_auth_secret_v2, null)
  umbrella_sig_auth_key     = try(local.settings.cloud_provider_settings.umbrella_sig_auth_key, null)
  umbrella_sig_auth_secret  = try(local.settings.cloud_provider_settings.umbrella_sig_auth_secret, null)
  umbrella_dns_auth_key     = try(local.settings.cloud_provider_settings.umbrella_dns_auth_key, null)
  umbrella_dns_auth_secret  = try(local.settings.cloud_provider_settings.umbrella_dns_auth_secret, null)
  zscaler_organization      = try(local.settings.cloud_provider_settings.zscaler_organization, null)
  zscaler_partner_base_uri  = try(local.settings.cloud_provider_settings.zscaler_partner_base_uri, null)
  zscaler_partner_key       = try(local.settings.cloud_provider_settings.zscaler_partner_key, null)
  zscaler_username          = try(local.settings.cloud_provider_settings.zscaler_username, null)
  zscaler_password          = try(local.settings.cloud_provider_settings.zscaler_password, null)
  cisco_sse_org_id          = try(local.settings.cloud_provider_settings.cisco_sse_org_id, null)
  cisco_sse_auth_key        = try(local.settings.cloud_provider_settings.cisco_sse_auth_key, null)
  cisco_sse_auth_secret     = try(local.settings.cloud_provider_settings.cisco_sse_auth_secret, null)
  cisco_sse_context_sharing = try(local.settings.cloud_provider_settings.cisco_sse_context_sharing, null)
}
