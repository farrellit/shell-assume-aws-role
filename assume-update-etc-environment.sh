function assume {
  region=us-east-1
  role=$1
  token=$2
  duration=900
  file="/etc/environment"
  touch $file
  echo "Access key id? "
  read id
  echo "Secret access key? "
  read key
  echo "Token? "
  read token
  AWS_ACCESS_KEY_ID=$id
  AWS_SECRET_ACCESS_KEY=$key
  unset AWS_SESSION_TOKEN
  export AWS_SESSION_TOKEN
  echo "Type in your SUDO password to authorize updates to /etc/environment: "
  sudo true
  if echo "$4" | grep "^[0-9]\{3,4\}$" > /dev/null; then duration=$4; fi
  mfa_device="$(aws --region $region iam list-mfa-devices --query MFADevices[0].SerialNumber --output text  )"
  result="$(aws --region $region \
    sts assume-role --role-arn "$role" \
    --serial-number "$mfa_device" --role-session-name "`whoami`" --duration-seconds "$duration" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text --token-code "$token" \
  )"
  if [ $? -ne 0 ]; then 
      echo "Failed to assume role" 1>&2; return 1; 
  else
    sed -i -e '/^AWS_ACCESS_KEY_ID=/d' -e '/^AWS_SECRET_KEY=/d /^AWS_SESSSION_TOKEN=/d'
    _AWS_ACCESS_KEY_ID="`echo $result | awk '{ print $1 }'`"
    _AWS_SECRET_ACCESS_KEY="`echo $result | awk '{ print $2 }'`"
    _AWS_SESSION_TOKEN="`echo $result | awk '{ print $3 }'`"
    sudo bash -c 'echo "export AWS_ACCESS_KEY_ID=\"$_AWS_ACCESS_KEY_ID\"" >> $file; echo "export AWS_SECRET_ACCESS_KEY=\"$_AWS_SECRET_ACCESS_KEY\"" >> $file; echo "export AWS_SESSION_TOKEN=\"$_AWS_SESSION_TOKEN\"" >> $file'
    return 0
  fi
}
