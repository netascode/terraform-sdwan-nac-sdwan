from nac_validate import RuleBase, Violation


class Rule(RuleBase):
    id = "413"
    description = "Validate access lists"
    severity = "HIGH"

    title = "INVALID ACCESS LIST SEQUENCE"
    affected_items_label = "ACL sequences"
    explanation = """\
The match entries and actions of an IPv4/IPv6 ACL sequence must be
consistent. ICMP message matches require protocol 1 only, a sequence
dropping traffic cannot also set, redirect, mirror, police or service
chain it, and a service chain needs both its name and its VPN (a fallback
needs at least one of them). SD-WAN Manager rejects such sequences."""
    recommendation = """\
Fix the ACL sequence so that its match entries and actions agree:

  sdwan:
    feature_profiles:
      service_profiles:
        - name: SERVICE
          ipv4_acls:
            - name: ACL1
              default_action: drop
              sequences:
                - id: 1
                  base_action: accept
                  match_entries:
                    protocols: [1]
                    icmp_messages: [echo]
                  actions:
                    service_chain_name: SC1
                    service_chain_vpn: 10
                    service_chain_fallback: true"""

    # Actions not allowed on an IPv4 sequence with base_action drop.
    IPV4_DROP_INVALID_ACTIONS = [
        "dscp",
        "ipv4_next_hop",
        "mirror",
        "policer",
        "service_chain_fallback",
        "service_chain_fallback_variable",
        "service_chain_name",
        "service_chain_name_variable",
        "service_chain_vpn",
        "service_chain_vpn_variable",
    ]
    # The only actions allowed on an IPv6 sequence with base_action drop.
    IPV6_DROP_VALID_ACTIONS = ["log", "counter_name"]
    SERVICE_CHAIN_NAME = ["service_chain_name", "service_chain_name_variable"]
    SERVICE_CHAIN_VPN = ["service_chain_vpn", "service_chain_vpn_variable"]
    SERVICE_CHAIN_FALLBACK = ["service_chain_fallback", "service_chain_fallback_variable"]

    @classmethod
    def _icmp(cls, sequence, path, details):
        match_entries = sequence.get("match_entries") or {}
        if not match_entries.get("icmp_messages"):
            return
        protocols = match_entries.get("protocols")
        if not protocols:
            yield Violation(
                message="ICMP messages are matched but protocol 1 is not matched",
                path=f"{path}.match_entries.protocols",
                details={**details, "protocols": protocols},
            )
        elif protocols != [1]:
            yield Violation(
                message=f"ICMP messages are matched but protocols is {protocols} instead of [1]",
                path=f"{path}.match_entries.protocols",
                details={**details, "protocols": protocols},
            )

    @classmethod
    def _drop_actions(cls, sequence, acl_type, path, details):
        if sequence.get("base_action") != "drop":
            return
        actions = sequence.get("actions") or {}
        if acl_type == "ipv4_acls":
            invalid = [action for action in cls.IPV4_DROP_INVALID_ACTIONS if action in actions]
        else:
            invalid = [action for action in actions if action not in cls.IPV6_DROP_VALID_ACTIONS]
        if invalid:
            yield Violation(
                message=f"Base action is drop but the sequence also has actions: {', '.join(invalid)}",
                path=f"{path}.actions",
                details={**details, "actions": invalid},
            )

    @classmethod
    def _service_chain(cls, sequence, path, details):
        actions = sequence.get("actions") or {}
        has_name_key = any(key in actions for key in cls.SERVICE_CHAIN_NAME)
        has_vpn_key = any(key in actions for key in cls.SERVICE_CHAIN_VPN)
        has_name = any(actions.get(key) for key in cls.SERVICE_CHAIN_NAME)
        has_vpn = any(actions.get(key) for key in cls.SERVICE_CHAIN_VPN)
        has_fallback = any(actions.get(key) for key in cls.SERVICE_CHAIN_FALLBACK)
        if has_name_key and not has_vpn:
            yield Violation(
                message="Service chain name is defined but service_chain_vpn is missing",
                path=f"{path}.actions.service_chain_vpn",
                details=details,
            )
        if has_vpn_key and not has_name:
            yield Violation(
                message="Service chain VPN is defined but service_chain_name is missing",
                path=f"{path}.actions.service_chain_name",
                details=details,
            )
        if has_fallback and not has_name and not has_vpn:
            yield Violation(
                message="Service chain fallback is defined but both service_chain_name and service_chain_vpn are missing",
                path=f"{path}.actions.service_chain_fallback",
                details=details,
            )

    @classmethod
    def match(cls, inventory):
        violations = []
        feature_profiles = (inventory.get("sdwan") or {}).get("feature_profiles") or {}
        for profile_type in ("transport_profiles", "service_profiles"):
            for profile in feature_profiles.get(profile_type) or []:
                profile_name = profile.get("name", "")
                for acl_type in ("ipv4_acls", "ipv6_acls"):
                    for acl in profile.get(acl_type) or []:
                        acl_name = acl.get("name", "")
                        for sequence in acl.get("sequences") or []:
                            sequence_id = sequence.get("id")
                            path = (
                                f"sdwan.feature_profiles.{profile_type}[name={profile_name}]"
                                f".{acl_type}[name={acl_name}].sequences[id={sequence_id}]"
                            )
                            details = {"feature_profile": profile_name, "acl": acl_name, "sequence": sequence_id}
                            if acl_type == "ipv4_acls":
                                violations.extend(cls._icmp(sequence, path, details))
                            violations.extend(cls._drop_actions(sequence, acl_type, path, details))
                            violations.extend(cls._service_chain(sequence, path, details))
        return violations
