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
resource "random_password" "client_secret" {
  for_each = var.apps_config

  length  = 32
  special = false
}

# Generate distinct secure Client IDs
resource "random_string" "client_id" {
  for_each = var.apps_config

  length  = 24
  special = false
  upper   = false
}

# Provision OAuth2/OIDC Providers
resource "authentik_provider_oauth2" "oauth2" {
  for_each = var.apps_config

  name               = "${each.value.name}-provider"
  client_id          = random_string.client_id[each.key].result
  client_secret      = random_password.client_secret[each.key].result
  authorization_flow = each.value.authorization_flow_uuid
  redirect_uris      = each.value.redirect_uris
  property_mappings  = each.value.property_mappings
}

# Provision Authentik Applications mapped to their unique provider
resource "authentik_application" "app" {
  for_each = var.apps_config

  name            = each.value.name
  slug            = each.value.slug
  provider_id     = authentik_provider_oauth2.oauth2[each.key].id
  open_in_new_tab = true
}

# Push independent Ecosystem Configurations to individual Vault Engine paths
resource "vault_kv_secret_v2" "oauth_config" {
  for_each = var.apps_config

  mount = each.value.vault_mount
  name  = each.value.vault_secret_name

  data_json = jsonencode({
    client_id     = random_string.client_id[each.key].result
    client_secret = random_password.client_secret[each.key].result
    redirect_uris = join(",", each.value.redirect_uris)
    auth_url      = "${stringtrimright(var.authentik_base_url, "/")}/application/o/authorize/"
    token_url     = "${stringtrimright(var.authentik_base_url, "/")}/application/o/token/"
    userinfo_url  = "${stringtrimright(var.authentik_base_url, "/")}/application/o/userinfo/"
  })
}
