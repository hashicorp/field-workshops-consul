output "aws_consul_iam_role_arn" {
  value = aws_iam_role.consul.arn
}

output "aws_consul_iam_instance_profile_name" {
  value = aws_iam_instance_profile.consul.name
}

output "aws_cts_iam_role_arn" {
  value = aws_iam_role.cts.arn
}

output "aws_cts_iam_instance_profile_name" {
  value = aws_iam_instance_profile.cts.name
}

output "aws_nomad_iam_role_arn" {
  value = aws_iam_role.nomad.arn
}

output "aws_nomad_iam_instance_profile_name" {
  value = aws_iam_instance_profile.nomad.name
}

output "azure_consul_user_assigned_identity_name" {
  value = azurerm_user_assigned_identity.consul.name
}

output "azure_consul_user_assigned_identity_principal_id" {
  value = azurerm_user_assigned_identity.consul.principal_id
}

output "azure_consul_user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.consul.id
}

output "azure_product_api_user_assigned_identity_name" {
  value = azurerm_user_assigned_identity.product-api.name
}

output "azure_product_api_user_assigned_identity_principal_id" {
  value = azurerm_user_assigned_identity.product-api.principal_id
}

output "azure_product_api_user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.product-api.id
}

output "gcp_consul_service_account_email" {
  value = google_service_account.consul.email
}
