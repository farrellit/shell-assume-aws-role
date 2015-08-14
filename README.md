
## Usage

where `dev` is the profile name from `~/.aws/`, `arn:aws:iam::01234567890:role/...` is the role of the arn, and `123456` is your current Session Token:

<pre>
source assume_role.sh
assume dev arn:aws:iam::01234567890:role/... 123456
</pre>
