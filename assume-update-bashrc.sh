function assume {
  region=us-east-1
  profile=$1
  role=$2
  token=$3
  duration=900
  if echo "$4" | grep "^[0-9]\{3,4\}$" > /dev/null; then duration=$4; fi
  mfa_device="$(aws --profile $profile --region $region iam list-mfa-devices --query MFADevices[0].SerialNumber --output text  )"
  result="$(aws --profile $profile --region $region \
    sts assume-role --role-arn "$role" \
    --serial-number "$mfa_device" --role-session-name "`whoami`" --duration-seconds "$duration" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text --token-code "$token" \
  )"
  if [ $? -ne 0 ]; then 
      echo "Failed to assume role" 1>&2; return 1; 
  else
    AWS_ACCESS_KEY_ID="`echo $result | awk '{ print $1 }'`"
    AWS_SECRET_ACCESS_KEY="`echo $result | awk '{ print $2 }'`"
    AWS_SESSION_TOKEN="`echo $result | awk '{ print $3 }'`"
    sed -i.bak -e "s/^AWS_ACCESS_KEY_ID=.*$/AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID/" -e "s/^AWS_SECRET_ACCESS_KEY=.*/AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY/" -e "s/^AWS_SESSION_TOKEN=.*$/AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN/"
    return 0
  fi
}
