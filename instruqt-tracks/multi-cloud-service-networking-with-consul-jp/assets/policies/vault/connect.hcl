path "connect-root/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "connect-intermediate*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/mounts"
{
  capabilities = ["create","update","read","sudo"]
}
path "sys/mounts/*"
{
  capabilities = ["create","update","read","sudo"]
}
path "auth/token/lookup" {
  capabilities = ["create","update"]
}
