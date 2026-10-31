locals {
  sig_security_providers = {
    generic  = "Generic"
    zscaler  = "Zscaler"
    umbrella = "Umbrella"
  }
}

resource "sdwan_sig_security_sig_feature" "sig_security_sig_feature" {
  for_each = {
    for sig_item in flatten([
      for profile in try(local.feature_profiles.sig_security_profiles, []) :
      try(profile.sig, null) != null ? [{
        profile = profile
        sig     = profile.sig
      }] : []
    ])
    : "${sig_item.profile.name}-sig" => sig_item
  }
  name                          = each.value.sig.name
  description                   = try(each.value.sig.description, null)
  feature_profile_id            = sdwan_sig_security_feature_profile.sig_security_feature_profile[each.value.profile.name].id
  sig_provider                  = local.sig_security_providers[each.value.sig.provider]
  aup_enabled                   = try(each.value.sig.aup_enabled, null)
  aup_timeout                   = try(each.value.sig.aup_timeout, null)
  auth_required                 = try(each.value.sig.auth_required, null)
  block_internet_until_accepted = try(each.value.sig.block_internet_until_accepted, null)
  caution_enabled               = try(each.value.sig.caution_enabled, null)
  display_time_unit             = try(each.value.sig.display_time_unit, null)
  force_ssl_inspection          = try(each.value.sig.force_ssl_inspection, null)
  idle_time                     = try(each.value.sig.idle_time, null)
  interface_pairs = try(length(each.value.sig.interface_pairs) == 0, true) ? null : [for item in each.value.sig.interface_pairs : {
    active_interface        = try(item.active_interface, null)
    active_interface_weight = try(item.active_interface_weight, null)
    backup_interface        = try(item.backup_interface, null)
    backup_interface_weight = try(item.backup_interface_weight, null)
  }]
  interfaces = [for item in each.value.sig.interfaces : {
    auto                             = try(item.auto, null)
    dpd_interval                     = try(item.dpd_interval, null)
    dpd_interval_variable            = try("{{${item.dpd_interval_variable}}}", null)
    dpd_retries                      = try(item.dpd_retries, null)
    dpd_retries_variable             = try("{{${item.dpd_retries_variable}}}", null)
    ike_ciphersuite                  = try(item.ike_ciphersuite, null)
    ike_ciphersuite_variable         = try("{{${item.ike_ciphersuite_variable}}}", null)
    ike_group                        = try(item.ike_group, null)
    ike_group_variable               = try("{{${item.ike_group_variable}}}", null)
    ike_local_id                     = try(item.ike_local_id, null)
    ike_local_id_variable            = try("{{${item.ike_local_id_variable}}}", null)
    ike_rekey_interval               = try(item.ike_rekey_interval, null)
    ike_rekey_interval_variable      = try("{{${item.ike_rekey_interval_variable}}}", null)
    ike_remote_id                    = try(item.ike_remote_id, null)
    ike_remote_id_variable           = try("{{${item.ike_remote_id_variable}}}", null)
    ike_version                      = try(item.ike_version, null)
    ike_version_variable             = try("{{${item.ike_version_variable}}}", null)
    interface_description            = try(item.interface_description, null)
    interface_description_variable   = try("{{${item.interface_description_variable}}}", null)
    interface_name                   = item.interface_name
    ipsec_ciphersuite                = try(item.ipsec_ciphersuite, null)
    ipsec_ciphersuite_variable       = try("{{${item.ipsec_ciphersuite_variable}}}", null)
    ipsec_rekey_interval             = try(item.ipsec_rekey_interval, null)
    ipsec_rekey_interval_variable    = try("{{${item.ipsec_rekey_interval_variable}}}", null)
    ipsec_replay_window              = try(item.ipsec_replay_window, null)
    ipsec_replay_window_variable     = try("{{${item.ipsec_replay_window_variable}}}", null)
    ipv4_address                     = try(item.ipv4_address, null)
    ipv4_address_variable            = try("{{${item.ipv4_address_variable}}}", null)
    mtu                              = try(item.mtu, null)
    mtu_variable                     = try("{{${item.mtu_variable}}}", null)
    perfect_forward_secrecy          = try(item.perfect_forward_secrecy, null)
    perfect_forward_secrecy_variable = try("{{${item.perfect_forward_secrecy_variable}}}", null)
    pre_shared_key_dynamic           = null # not supported in the UI
    pre_shared_secret                = try(item.pre_shared_secret, null)
    pre_shared_secret_variable       = try("{{${item.pre_shared_secret_variable}}}", null)
    shutdown                         = try(item.shutdown, null)
    tcp_mss_adjust                   = try(item.tcp_mss_adjust, null)
    tcp_mss_adjust_variable          = try("{{${item.tcp_mss_adjust_variable}}}", null)
    track_enable                     = try(item.track_enable, null)
    tracker                          = try(item.tracker, null)
    tunnel_dc_preference             = try(item.tunnel_dc_preference, null)
    tunnel_destination               = try(item.tunnel_destination, null)
    tunnel_destination_variable      = try("{{${item.tunnel_destination_variable}}}", null)
    tunnel_public_ip                 = try(item.tunnel_public_ip, null)
    tunnel_public_ip_variable        = try("{{${item.tunnel_public_ip_variable}}}", null)
    tunnel_route_via                 = try(item.tunnel_route_via, null)
    tunnel_route_via_variable        = try("{{${item.tunnel_route_via_variable}}}", null)
    tunnel_set                       = try(item.tunnel_set, null)
    tunnel_source                    = try(item.tunnel_source, null)
    tunnel_source_variable           = try("{{${item.tunnel_source_variable}}}", null)
    tunnel_source_interface          = try(item.tunnel_source_interface, null)
    tunnel_source_interface_variable = try("{{${item.tunnel_source_interface_variable}}}", null)
    unnumbered                       = try(item.unnumbered, null)
  }]
  ip_enforced_for_known_browsers          = try(each.value.sig.ip_enforced_for_known_browsers, null)
  ips_control                             = try(each.value.sig.ips_control, null)
  location_name                           = null # not supported in the UI
  location_name_variable                  = try("{{${each.value.sig.location_name_variable}}}", null)
  ofw_enabled                             = try(each.value.sig.firewall_enabled, null)
  primary_data_center                     = try(each.value.sig.primary_data_center, null)
  primary_data_center_variable            = try("{{${each.value.sig.primary_data_center_variable}}}", null)
  refresh_time                            = try(each.value.sig.refresh_time, null)
  refresh_time_unit                       = try(each.value.sig.refresh_time_unit, null)
  secondary_data_center                   = try(each.value.sig.secondary_data_center, null)
  secondary_data_center_variable          = try("{{${each.value.sig.secondary_data_center_variable}}}", null)
  src_vpn                                 = try(each.value.sig.src_vpn, null)
  surrogate_ip                            = try(each.value.sig.surrogate_ip, null)
  tracker_source_ip                       = try(each.value.sig.tracker_source_ip, null)
  tracker_source_ip_variable              = try("{{${each.value.sig.tracker_source_ip_variable}}}", null)
  umbrella_primary_data_center            = try(each.value.sig.umbrella_primary_data_center, null)
  umbrella_primary_data_center_variable   = try("{{${each.value.sig.umbrella_primary_data_center_variable}}}", null)
  umbrella_secondary_data_center          = try(each.value.sig.umbrella_secondary_data_center, null)
  umbrella_secondary_data_center_variable = try("{{${each.value.sig.umbrella_secondary_data_center_variable}}}", null)
  trackers = try(length(each.value.sig.trackers) == 0, true) ? null : [for item in each.value.sig.trackers : {
    name                      = try(item.name, null)
    endpoint_api_url          = try(item.endpoint_api_url, null)
    endpoint_api_url_variable = try("{{${item.endpoint_api_url_variable}}}", null)
    interval                  = try(item.interval, null)
    interval_variable         = try("{{${item.interval_variable}}}", null)
    multiplier                = try(item.multiplier, null)
    multiplier_variable       = try("{{${item.multiplier_variable}}}", null)
    threshold                 = try(item.threshold, null)
    threshold_variable        = try("{{${item.threshold_variable}}}", null)
  }]
  xff_forward_enabled = try(each.value.sig.xff_forward_enabled, null)
}
