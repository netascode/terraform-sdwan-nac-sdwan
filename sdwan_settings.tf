
resource "sdwan_cloud_provider_settings" "cloud_provider_settings" {
  count                               = try(local.settings.cloud_provider_settings, null) != null ? 1 : 0
  umbrella_org_id                     = try(local.settings.cloud_provider_settings.umbrella_org_id, null)
  umbrella_auth_key_v2                = try(local.settings.cloud_provider_settings.umbrella_auth_key_v2_version, null) == null ? try(local.settings.cloud_provider_settings.umbrella_auth_key_v2, null) : null
  umbrella_auth_key_v2_wo             = try(local.settings.cloud_provider_settings.umbrella_auth_key_v2_version, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_auth_key_v2, null)
  umbrella_auth_key_v2_wo_version     = try(local.settings.cloud_provider_settings.umbrella_auth_key_v2, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_auth_key_v2_version, null)
  umbrella_auth_secret_v2             = try(local.settings.cloud_provider_settings.umbrella_auth_secret_v2_version, null) == null ? try(local.settings.cloud_provider_settings.umbrella_auth_secret_v2, null) : null
  umbrella_auth_secret_v2_wo          = try(local.settings.cloud_provider_settings.umbrella_auth_secret_v2_version, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_auth_secret_v2, null)
  umbrella_auth_secret_v2_wo_version  = try(local.settings.cloud_provider_settings.umbrella_auth_secret_v2, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_auth_secret_v2_version, null)
  umbrella_sig_auth_key               = try(local.settings.cloud_provider_settings.umbrella_sig_auth_key_version, null) == null ? try(local.settings.cloud_provider_settings.umbrella_sig_auth_key, null) : null
  umbrella_sig_auth_key_wo            = try(local.settings.cloud_provider_settings.umbrella_sig_auth_key_version, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_sig_auth_key, null)
  umbrella_sig_auth_key_wo_version    = try(local.settings.cloud_provider_settings.umbrella_sig_auth_key, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_sig_auth_key_version, null)
  umbrella_sig_auth_secret            = try(local.settings.cloud_provider_settings.umbrella_sig_auth_secret_version, null) == null ? try(local.settings.cloud_provider_settings.umbrella_sig_auth_secret, null) : null
  umbrella_sig_auth_secret_wo         = try(local.settings.cloud_provider_settings.umbrella_sig_auth_secret_version, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_sig_auth_secret, null)
  umbrella_sig_auth_secret_wo_version = try(local.settings.cloud_provider_settings.umbrella_sig_auth_secret, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_sig_auth_secret_version, null)
  umbrella_dns_auth_key               = try(local.settings.cloud_provider_settings.umbrella_dns_auth_key_version, null) == null ? try(local.settings.cloud_provider_settings.umbrella_dns_auth_key, null) : null
  umbrella_dns_auth_key_wo            = try(local.settings.cloud_provider_settings.umbrella_dns_auth_key_version, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_dns_auth_key, null)
  umbrella_dns_auth_key_wo_version    = try(local.settings.cloud_provider_settings.umbrella_dns_auth_key, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_dns_auth_key_version, null)
  umbrella_dns_auth_secret            = try(local.settings.cloud_provider_settings.umbrella_dns_auth_secret_version, null) == null ? try(local.settings.cloud_provider_settings.umbrella_dns_auth_secret, null) : null
  umbrella_dns_auth_secret_wo         = try(local.settings.cloud_provider_settings.umbrella_dns_auth_secret_version, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_dns_auth_secret, null)
  umbrella_dns_auth_secret_wo_version = try(local.settings.cloud_provider_settings.umbrella_dns_auth_secret, null) == null ? null : try(local.settings.cloud_provider_settings.umbrella_dns_auth_secret_version, null)
  zscaler_organization                = try(local.settings.cloud_provider_settings.zscaler_organization, null)
  zscaler_partner_base_uri            = try(local.settings.cloud_provider_settings.zscaler_partner_base_uri, null)
  zscaler_partner_key                 = try(local.settings.cloud_provider_settings.zscaler_partner_key_version, null) == null ? try(local.settings.cloud_provider_settings.zscaler_partner_key, null) : null
  zscaler_partner_key_wo              = try(local.settings.cloud_provider_settings.zscaler_partner_key_version, null) == null ? null : try(local.settings.cloud_provider_settings.zscaler_partner_key, null)
  zscaler_partner_key_wo_version      = try(local.settings.cloud_provider_settings.zscaler_partner_key, null) == null ? null : try(local.settings.cloud_provider_settings.zscaler_partner_key_version, null)
  zscaler_username                    = try(local.settings.cloud_provider_settings.zscaler_username, null)
  zscaler_password                    = try(local.settings.cloud_provider_settings.zscaler_password_version, null) == null ? try(local.settings.cloud_provider_settings.zscaler_password, null) : null
  zscaler_password_wo                 = try(local.settings.cloud_provider_settings.zscaler_password_version, null) == null ? null : try(local.settings.cloud_provider_settings.zscaler_password, null)
  zscaler_password_wo_version         = try(local.settings.cloud_provider_settings.zscaler_password, null) == null ? null : try(local.settings.cloud_provider_settings.zscaler_password_version, null)
  cisco_sse_org_id                    = try(local.settings.cloud_provider_settings.cisco_sse_org_id, null)
  cisco_sse_auth_key                  = try(local.settings.cloud_provider_settings.cisco_sse_auth_key_version, null) == null ? try(local.settings.cloud_provider_settings.cisco_sse_auth_key, null) : null
  cisco_sse_auth_key_wo               = try(local.settings.cloud_provider_settings.cisco_sse_auth_key_version, null) == null ? null : try(local.settings.cloud_provider_settings.cisco_sse_auth_key, null)
  cisco_sse_auth_key_wo_version       = try(local.settings.cloud_provider_settings.cisco_sse_auth_key, null) == null ? null : try(local.settings.cloud_provider_settings.cisco_sse_auth_key_version, null)
  cisco_sse_auth_secret               = try(local.settings.cloud_provider_settings.cisco_sse_auth_secret_version, null) == null ? try(local.settings.cloud_provider_settings.cisco_sse_auth_secret, null) : null
  cisco_sse_auth_secret_wo            = try(local.settings.cloud_provider_settings.cisco_sse_auth_secret_version, null) == null ? null : try(local.settings.cloud_provider_settings.cisco_sse_auth_secret, null)
  cisco_sse_auth_secret_wo_version    = try(local.settings.cloud_provider_settings.cisco_sse_auth_secret, null) == null ? null : try(local.settings.cloud_provider_settings.cisco_sse_auth_secret_version, null)
  cisco_sse_context_sharing           = try(local.settings.cloud_provider_settings.cisco_sse_context_sharing, null)
}
