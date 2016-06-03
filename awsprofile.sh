## This shell function sets key and secret from a named profile in ~/.aws/

awsprofile() {
	export profile=$1
	export AWS_ACCESS_KEY_ID="$(aws --profile $profile configure get aws_access_key_id)"
	export AWS_SECRET_ACCESS_KEY="$(aws --profile $profile configure get aws_secret_access_key)"
	unset AWS_TOKEN
	unset AWS_SESSION_TOKEN
}
