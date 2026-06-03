locals {
  oidc_provider_host = replace(var.oidc_provider_url, "https://", "")
}