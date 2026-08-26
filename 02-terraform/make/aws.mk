.PHONY: aws.vpcs
aws.vpcs:
	@aws ec2 describe-vpcs --query 'Vpcs[0].VpcId' --filters "Name=is-default,Values=true" --output text
