## Assume a role without region or MFA, or Profile
## Perfect for Jenkins jobs to achieve cross-account access

## This function takes only one argument, the role name.  

assume() {
  role="$1"
  duration=1800
  result="$(aws sts assume-role --role-arn "$role" \
   --role-session-name "PublicAssetsDeployment" --duration-seconds "$duration" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text \
  )"
  if [ $? -ne 0 ]; then 
      echo "Failed to assume role" 1>&2; return 1; 
  else
    export AWS_ACCESS_KEY_ID="`echo $result | awk '{ print $1 }'`"
    export AWS_SECRET_ACCESS_KEY="`echo $result | awk '{ print $2 }'`"
    export AWS_SESSION_TOKEN="`echo $result | awk '{ print $3 }'`"
    return 0
  fi
}
