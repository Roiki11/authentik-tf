variable "authentik_base_url" {
  type        = string
  description = "The root URL of your Authentik instance (e.g., https://company.local)."
}
 variable "vault_kv_mount" {
  type        = string
  description = "The mount path of the Vault KV v2 secrets engine where the OAuth2/OIDC provider configurations will be stored."
 }
 variable "vault_authentik_oauth2_path" {
  type        = string
  description = "The path within the Vault KV v2 secrets engine where the OAuth2/OIDC provider configurations will be stored."
  default     = "authentik/oauth2"
}
variable "password_version" {
  type    = number
  default = 1
}
variable "apps_config" {
  type = map(object({
    name                       = string
    slug                       = string
    authorization_flow_uuid    = string
    redirect_uris              = list(string)
    property_mappings          = optional(list(string), ["scope-openid", "scope-profile", "scope-email"])
    backchannel_providers      = optional(list(string), [])
    group                      = optional(string, null)
    meta_description           = optional(string, null)
    meta_hide                  = optional(bool, false)
    meta_icon                  = optional(string, null)
    meta_launch_url            = optional(string, null)
    meta_publisher             = optional(string, null)
    open_in_new_tab            = optional(bool, false)
    policy_engine_mode         = optional(string, [all, any])
    protocol_provider          = optional(string, null)
    access_code_validity       = optional(string, null)
    access_token_validity      = optional(string, null)
    allowed_redirect_uris      = optional(list(map(string)), [])
    authentication_flow        = optional(string, null)
    client_secret              = optional(string, null)
    client_type                = optional(string, "confidential")
    encryption_key             = optional(string, null)
    grant_types                = optional(list(string), [])
    include_claims_in_id_token = optional(bool, true)
    issuer_mode                = optional(string, "per_provider")
    jwks_sources               = optional(list(string), [])
    jwt_federation_providers   = optional(list(number), [])
    jwt_federation_sources     = optional(list(string), [])
    logout_method              = optional(string, "backchannel")
    logout_uri                 = optional(string, null)
    property_mappings          = optional(list(string), [])
    refresh_token_threshold    = optional(string, "seconds=0")
    refresh_token_validity     = optional(string, "days=30")
    signing_key                = optional(string, null)
    sub_mode                   = optional(string, null)
  }))
  description = "A map configurations to provision multiple Authentik applications and sync them to Vault."

  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.client_type == "confidential" || app.client_type == "public"])
    error_message = "Each application configuration must specify a valid client_type ('confidential' or 'public')."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.policy_engine_mode == null || app.policy_engine_mode == "all" || app.policy_engine_mode == "any"])
    error_message = "Each application configuration must specify a valid policy_engine_mode ('all', 'any', or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.issuer_mode == null || app.issuer_mode == "per_provider" || app.issuer_mode == "per_application"])
    error_message = "Each application configuration must specify a valid issuer_mode ('per_provider', 'per_application', or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.logout_method == null || app.logout_method == "backchannel" || app.logout_method == "frontchannel"])
    error_message = "Each application configuration must specify a valid logout_method ('backchannel', 'frontchannel', or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.include_claims_in_id_token == null || app.include_claims_in_id_token == true || app.include_claims_in_id_token == false])
    error_message = "Each application configuration must specify a valid include_claims_in_id_token (true, false, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.refresh_token_threshold == null || can(regex("^seconds=\\d+$", app.refresh_token_threshold))])
    error_message = "Each application configuration must specify a valid refresh_token_threshold (e.g., 'seconds=0', 'seconds=30', or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.refresh_token_validity == null || can(regex("^(seconds|minutes|hours|days|weeks|months|years)=\\d+$", app.refresh_token_validity))])
    error_message = "Each application configuration must specify a valid refresh_token_validity (e.g., 'days=30', 'hours=12', or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.access_code_validity == null || can(regex("^(seconds|minutes|hours|days|weeks|months|years)=\\d+$", app.access_code_validity))])
    error_message = "Each application configuration must specify a valid access_code_validity (e.g., 'seconds=30', 'minutes=5', or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.access_token_validity == null || can(regex("^(seconds|minutes|hours|days|weeks|months|years)=\\d+$", app.access_token_validity))])
    error_message = "Each application configuration must specify a valid access_token_validity (e.g., 'hours=1', 'days=7', or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.logout_uri == null || can(regex("^https?://", app.logout_uri))])
    error_message = "Each application configuration must specify a valid logout_uri (must start with 'http://' or 'https://', or be null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.meta_icon == null || can(regex("^[a-zA-Z0-9_-]+$", app.meta_icon))])
    error_message = "Each application configuration must specify a valid meta_icon (alphanumeric, underscores, or hyphens, or be null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.meta_launch_url == null || can(regex("^https?://", app.meta_launch_url))])
    error_message = "Each application configuration must specify a valid meta_launch_url (must start with 'http://' or 'https://', or be null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.meta_publisher == null || can(regex("^[a-zA-Z0-9_-]+$", app.meta_publisher))])
    error_message = "Each application configuration must specify a valid meta_publisher (alphanumeric, underscores, or hyphens, or be null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.group == null || can(regex("^[a-zA-Z0-9_-]+$", app.group))])
    error_message = "Each application configuration must specify a valid group (alphanumeric, underscores, or hyphens, or be null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.protocol_provider == null || can(regex("^[a-zA-Z0-9_-]+$", app.protocol_provider))])
    error_message = "Each application configuration must specify a valid protocol_provider (alphanumeric, underscores, or hyphens, or be null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.signing_key == null || can(regex("^[a-zA-Z0-9_-]+$", app.signing_key))])
    error_message = "Each application configuration must specify a valid signing_key (alphanumeric, underscores, or hyphens, or be null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.encryption_key == null || can(regex("^[a-zA-Z0-9_-]+$", app.encryption_key))])
    error_message = "Each application configuration must specify a valid encryption_key (alphanumeric, underscores, or hyphens, or be null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.jwt_federation_providers == null || alltrue([for id in app.jwt_federation_providers : can(regex("^[0-9]+$", tostring(id)))])])
    error_message = "Each application configuration must specify valid jwt_federation_providers (list of numeric IDs, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.jwt_federation_sources == null || alltrue([for source in app.jwt_federation_sources : can(regex("^[a-zA-Z0-9_-]+$", source))])])
    error_message = "Each application configuration must specify valid jwt_federation_sources (list of alphanumeric, underscores, or hyphens, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.jwks_sources == null || alltrue([for source in app.jwks_sources : can(regex("^[a-zA-Z0-9_-]+$", source))])])
    error_message = "Each application configuration must specify valid jwks_sources (list of alphanumeric, underscores, or hyphens, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.grant_types == null || alltrue([for grant in app.grant_types : can(regex("^[a-zA-Z0-9_-]+$", grant))])])
    error_message = "Each application configuration must specify valid grant_types (list of alphanumeric, underscores, or hyphens, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.property_mappings == null || alltrue([for mapping in app.property_mappings : can(regex("^[a-zA-Z0-9_-]+$", mapping))])])
    error_message = "Each application configuration must specify valid property_mappings (list of alphanumeric, underscores, or hyphens, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.allowed_redirect_uris == null || alltrue([for uri_map in app.allowed_redirect_uris : can(regex("^[a-zA-Z0-9_-]+$", uri_map["name"])) && can(regex("^https?://", uri_map["uri"]))])])
    error_message = "Each application configuration must specify valid allowed_redirect_uris (list of maps with 'name' and 'uri', where 'name' is alphanumeric, underscores, or hyphens, and 'uri' starts with 'http://' or 'https://', or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.authentication_flow == null || can(regex("^[a-zA-Z0-9_-]+$", app.authentication_flow))])
    error_message = "Each application configuration must specify a valid authentication_flow (alphanumeric, underscores, or hyphens, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.client_secret == null || can(regex("^[a-zA-Z0-9_-]+$", app.client_secret))])
    error_message = "Each application configuration must specify a valid client_secret (alphanumeric, underscores, or hyphens, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.client_id == null || can(regex("^[a-zA-Z0-9_-]+$", app.client_id))])
    error_message = "Each application configuration must specify a valid client_id (alphanumeric, underscores, or hyphens, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.authorization_flow_uuid == null || can(regex("^[a-zA-Z0-9_-]+$", app.authorization_flow_uuid))])
    error_message = "Each application configuration must specify a valid authorization_flow_uuid (alphanumeric, underscores, or hyphens, or null)."
  }
  validation {
    condition     = alltrue([for app in values(var.apps_config) : app.redirect_uris == null || alltrue([for uri in app.redirect_uris : can(regex("^https?://", uri))])])
    error_message = "Each application configuration must specify valid redirect_uris (list of URIs starting with 'http://' or 'https://', or null)."
  }
  validation {
    condition = alltrue([for app in values(var.apps_config) : app.sub_mode == null || app.sub_mode == contains(["standard", "implicit", "hashed_user_id", "hashed_user_uuid", "hashed_user_username", "hashed_user_email", "hashed_user_upn", "user_id", "user_uuid", "user_username", "user_email"])])
    error_message = "Each application configuration must specify a valid sub_mode (standard, implicit, hashed_user_id, hashed_user_uuid, hashed_user_username, hashed_user_email, hashed_user_upn, user_id, user_uuid, user_username, user_email, or null)."
  }
}
