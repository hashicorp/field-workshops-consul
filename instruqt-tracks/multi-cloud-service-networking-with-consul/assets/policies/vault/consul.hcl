path "kv/consul"
{
  capabilities = ["read"]
}
path "pki/issue/consul"
{
  capabilities = ["read","update"]
}
path "pki/cert/ca"
{
  capabilities = ["read"]
}
