# JWT Looks like
#{
#  "aud": "https://management.azure.com/",
#  "iss": "https://sts.windows.net/0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec/",
#  "iat": 1595598285,
#  "nbf": 1595598285,
#  "exp": 1595684985,
#  "aio": "E2BgYDDgbUu/cuX6X9+lv44s3e4gDwA=",
#  "appid": "16f36118-217b-4e7c-9250-69321b4c0742",
#  "appidacr": "2",
#  "idp": "https://sts.windows.net/0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec/",
#  "oid": "644d9b8a-b07e-46e8-b81e-bd3a4c997ce9",
#  "sub": "644d9b8a-b07e-46e8-b81e-bd3a4c997ce9",
#  "tid": "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec",
#  "uti": "yO3F62CSGkedkoxqPrkWAA",
#  "ver": "1.0",
#  "xms_mirid": "/subscriptions/28af6932-cb76-431f-ba61-5ec6d1e8b422/resourcegroups/nics-instruqt/providers/Microsoft.ManagedIdentity/userAssignedIdentities/payments"
#}


# Create the policy
consul acl policy create \
  -name "payments-policy" \
  -description "Policy for API service to grant agent permisions and consul connect integration" \
  -rules @payments_policy.hcl

# Create the role which is associated with the policy
consul acl role create \
  -name "payments-role" \
  -description "Role for the API service" \
  -policy-name "api-policy" \

# Create the Authentication Config for Azure
# The issuer needs to have the tennant id dynamically added to the bound issuer
export TENNANT_ID=0e3e2e88-8caf-41ca-b4da-e3b33b6c52ecl
cat <<EOF > ./jwt_auth_config.json
{
  "BoundAudiences": [
    "https://management.azure.com/"
  ],
  "BoundIssuer": "https://sts.windows.net/${TENNANT_ID}/",
  "JWTValidationPubKeys": [
      "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6lldKm5Rc/vMKa1RM/Tt\nUv3tmtj52wLRrJqu13yGM3/h0dwru2ZP53y65wDfz6/tLCjoYuRCuVsjoW37+0zX\nUORJvZ0L90CAX+58lW7NcE4bAzA1pXv7oR9kQw0X8dp0atU4HnHeaTU8LZxcjJO7\n9/H9cxgwa+clKfGxllcos8TsuurM8xi2dx5VqwzqNMB2s62l3MTN7AzctHUiQCiX\n2iJArGjAhs+mxS1wmyMIyOSipdodhjQWRAcseW+aFVyRTFVi8okl2cT1HJjPXdx0\nb1WqYSOzeRdrrLUcA0oR2Tzp7xzOYJZSGNnNLQqa9f6h6h52XbX0iAgxKgEDlRpb\nJwIDAQAB\n-----END PUBLIC KEY-----"
  ],
  "ClaimMappings": {
      "id": "xms_mirid"
  }
}
EOF

# Set the Auth config
consul acl auth-method create -name my-jwt -type jwt -config @jwt_auth_config.json

# Set the binding rule, we can associate a JWT to a binding-role using a selector
# This selector matches on the Managed Identity name which is the final part of the xms_mirid claim
consul acl binding-rule create -method=my-jwt -bind-type=role -bind-name=payments-role -selector='value.xms_mirid matches `.*/payments`'
