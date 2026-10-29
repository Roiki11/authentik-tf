terraform {
  required_version = ">= 1.3.0"
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2024.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}
# Generate distinct secure Client Secrets

# Generate distinct secure Client IDs
resource "random_string" "client_id" {
  for_each = var.apps_config

  length  = 24
  special = false
  upper   = false
}
data "authentik_flow" "default-authorization-flow" {
  slug = var.default_authorization_flow_slug
}
# Provision OAuth2/OIDC Providers
resource "authentik_provider_oauth2" "oauth2" {
  for_each = var.apps_config

  name               = "${each.value.name}-provider"
  client_id          = random_string.client_id[each.key].result
  authorization_flow = each.value.authorization_flow_uuid != null ? each.value.authorization_flow_uuid : data.authentik_flow.default-authorization-flow.id
  redirect_uris      = each.value.redirect_uris
  property_mappings  = each.value.property_mappings
}

# Provision Authentik Applications mapped to their unique provider
resource "authentik_application" "app" {
  for_each = var.apps_config

  name                  = each.value.name
  slug                  = each.value.slug
  provider_id           = authentik_provider_oauth2.oauth2[each.key].id
  backchannel_providers = each.value.backchannel_providers
  group                 = each.value.group
  meta_description      = each.value.meta_description
  meta_hide             = each.value.meta_hide
  meta_icon             = each.value.meta_icon
  meta_launch_url       = each.value.meta_launch_url
  meta_publisher        = each.value.meta_publisher
  open_in_new_tab       = each.value.open_in_new_tab
  policy_engine_mode    = each.value.policy_engine_mode
  protocol_provider     = each.value.protocol_provider
}

ephemeral "authentik_provider_oauth2_config" "oauth2_config" {
  for_each = var.apps_config
  name       = "${each.value.name}-provider"
  sensitive = true
}
# Push independent Ecosystem Configurations to individual Vault Engine paths
resource "vault_kv_secret_v2" "oauth_config" {
  for_each = data.authentik_provider_oauth2_config.oauth2_config
  depends_on = [
    random_string.client_id,
    random_password.client_secret,
    authentik_provider_oauth2.oauth2,
    authentik_application.app,
    authentik_provider_oauth2_config.oauth2_config
  ]
  mount = var.vault_kv_mount
  name  = "${var.vault_authentik_oauth2_path}/${each.key}"
  data_json_wo_version = var.password_version
  data_json_wo = jsonencode({
    client_id         = random_string.client_id[each.key].result
    client_secret     = ephemeral.authentik_provider_oauth2_config.oauth2_config[each.key].client_secret
    authorize_url     = each.value.authorize_url
    issuer_url        = each.value.issuer_url
    jwks_url          = each.value.jwks_url
    logout_url        = each.value.logout_url
    provider_info_url = each.value.provider_info_url
    token_url         = each.value.token_url
    user_info_url     = each.value.user_info_url
  })
}
