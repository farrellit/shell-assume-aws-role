function assume {
  set +x
  region=us-east-1
  profile=$1
  role=$2
  token=$3
  duration=900
  if echo "$4" | grep "^[0-9]\{3,4\}$" > /dev/null; then duration=$4; fi
  mfa_device='$(aws --profile $profile --region $region iam list-mfa-devices --query MFADevices[0].SerialNumber --output text  )'
  result="$(aws --profile $profile --region $region \
    sts assume-role --role-arn "$role" \
    --serial-number "$mfa_device" --role-session-name "`whoami`" --duration-seconds "$duration" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text --token-code "$token" \
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
