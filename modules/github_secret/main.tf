resource "github_actions_secret" "subscription_id" {
  repository      = var.repo_name
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = var.subscription_id
}

resource "github_actions_secret" "tenant_id" {
  repository      = var.repo_name
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = var.tenant_id
}

resource "github_actions_secret" "object_id" {
  repository      = var.repo_name
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = var.object_id
}
