# Get JWT token from the metadata service and write it to a file
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true -s | jq -r .access_token > ./meta.token

# Use the token to log into consul
consul login -method my-jwt -bearer-token-file ./meta.token -token-sink-file ./consul.token

# Refresh the token for the consul agent
consul acl set-agent-token -token-file /consul.token default $(cat ./consul.token)