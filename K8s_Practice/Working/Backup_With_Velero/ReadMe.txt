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

-------Export Velero bucket details to bash profile-----
$	echo "export VELERO_BUCKET=${VELERO_BUCKET}" | tee -a ~/.bash_profile

-------Create user name for velero to access AWS on your behalf to access backup files in S3-----------
$	aws iam create-user --user-name velero
------Create a policy for velero with all necessary perm.------
$	cat > velero-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${VELERO_BUCKET}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${VELERO_BUCKET}"
            ]
        }
    ]
}
EOF

------Attach created policy to velero IAM User------
$	aws iam put-user-policy \
  --user-name velero \
  --policy-name velero \
  --policy-document file://velero-policy.json

-------Create access key of the user--------
$	aws iam create-access-key --user-name velero > velero-access-key.json

-------Note down the access-key---------

$	Verify the access key created


--------Export Velero AccessKey and Secret to bash profile-----------

export VELERO_ACCESS_KEY_ID=$(cat velero-access-key.json | jq -r '.AccessKey.AccessKeyId')
export VELERO_SECRET_ACCESS_KEY=$(cat velero-access-key.json | jq -r '.AccessKey.SecretAccessKey')
echo "export VELERO_ACCESS_KEY_ID=${VELERO_ACCESS_KEY_ID}" | tee -a ~/.bash_profile
echo "export VELERO_SECRET_ACCESS_KEY=${VELERO_SECRET_ACCESS_KEY}" | tee -a ~/.bash_profile

---------Create velero credentials-----------------

cat > velero-credentials <<EOF
[default]
aws_access_key_id=$VELERO_ACCESS_KEY_ID
aws_secret_access_key=$VELERO_SECRET_ACCESS_KEY
EOF

-----------Install Velero---------

$	wget https://github.com/vmware-tanzu/velero/releases/download/v1.3.2/velero-v1.3.2-linux-amd64.tar.gz
$	tar -xvf velero-v1.3.2-linux-amd64.tar.gz -C /tmp
$	sudo mv /tmp/velero-v1.3.2-linux-amd64/velero /usr/local/bin
$	velero version
$	velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.0.1 \
    --bucket $VELERO_BUCKET \
    --backup-location-config region=$AWS_REGION \
    --snapshot-location-config region=$AWS_REGION \
    --secret-file ./velero-credentials

----------Deploy your application in a namespace--------

$	kubectl apply -f deployment file name

----------Backup your K8s deployment--------
$	velero backup create <backup-name> --include-namespaces <namespace-name>

-----------Check Status of your backup------
$	velero backup describe staging-backup

-----------Delete all obj in NS to create a disaster-------

$	kubectl delete namespace <namespace-name>

-----------Restore Backup from Velero to Same cluster--------

$	velero restore create --from-backup <backup-name>

----------Check Backup Status------------

$	velero restore get

-----------Check backed-up application------

$	kubectl get all -n <namespace-name>

----------------------------------This is how to create and restore a backup--------------------


----------------------------------Create and Restore to new cluster-----------------------

Make Sure Velero is installed and other pre-req like Iam Roles are setup

---------------------------Configure Velero for your Cluster-------------------
$	velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.0.1 \
    --bucket <S3-Bucket-URL> \
    --backup-location-config region=<Region-Name> \
    --snapshot-location-config region=<Region-Name> \
    --secret-file ./velero-credentials
-------------------------Check if your backup is listing by entering below command-------
$	velero get backup
------------------------Once your backup is listing restore it with below commands----------
$	velero restore create --from-backup <backup-name>

----------Check Backup Status------------

$	velero restore get

-----------Check backed-up application------

$	kubectl get all -n <namespace-name>

----------------------------------This is how to restore a backup to a new cluster--------------------
