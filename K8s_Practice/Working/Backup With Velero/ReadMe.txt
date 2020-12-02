--------Create a bucket for Velero--------
$	yum install jq -y

$	AWS_REGION=<Desired-Region-name>

$	export VELERO_BUCKET=$(aws s3api create-bucket \
--bucket velero-backup-$(date +%s)-$RANDOM \
--region $AWS_REGION \
--create-bucket-configuration LocationConstraint=$AWS_REGION \
--| jq -r '.Location' \
--| cut -d'/' -f3 \
--| cut -d'.' -f1)