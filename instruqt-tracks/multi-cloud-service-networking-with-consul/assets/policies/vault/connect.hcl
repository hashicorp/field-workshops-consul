path "connect-root/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "connect-intermediate/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/mounts"
{
  capabilities = ["read"]
}
path "auth/token/lookup" {
  capabilities = ["create","update"]
}
