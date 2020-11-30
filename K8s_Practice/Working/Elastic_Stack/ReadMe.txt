-------------------Mount EKS for Elastic Search----------------
-----------locate cluster VPC id with below commands-----------

$	EKS_CLUSTER="cluster_name"
$	EKS_VPC_ID=$(aws eks describe-cluster --name $EKS_CLUSTER --query "cluster.resourcesVpcConfig.vpcId" --output text)
$	echo $EKS_VPC_ID

-----------Locate the CIDR range for your cluster’s VPC-----------

$	EKS_VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $EKS_VPC_ID --query "Vpcs[].CidrBlock" --output text)
$	echo $EKS_VPC_CIDR

-----------Create a security group that allows inbound NFS traffic for your Amazon EFS mount points-----------

$	aws ec2 create-security-group --group-name efs-nfs-sg --description "Allow NFS traffic for EFS" --vpc-id $EKS_VPC_ID

-----------Take note of Security group ID:-----------

$	{
    "GroupId": "sg-0861017439bfcdd54"
	}

-----------Add rules to your security group:-----------

$	SG_ID="sg-0861017439bfcdd54"
$	aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 2049 --cidr $EKS_VPC_CIDR

-----------To view the changes to the security group, run the describe-security-groups command:-----------

$	aws ec2 describe-security-groups --group-ids $SG_ID

-----------Create the Amazon EFS file system for your Amazon EKS cluster:-----------

$	[ec2-user@ip-10-0-0-6 ~]$ aws efs create-file-system --region ap-south-1 (Region Name)
	{
		"SizeInBytes": {
			"ValueInIA": 0,
			"ValueInStandard": 0,
			"Value": 0
		},
		"FileSystemArn": "arn:aws:elasticfilesystem:ap-south-1:713367313056:file-system/fs-44205695",
		"ThroughputMode": "bursting",
		"CreationToken": "cbc04936-29ea-41e3-bf67-c37687a3102b",
		"Encrypted": false,
		"Tags": [],
		"CreationTime": 1606749122.0,
		"PerformanceMode": "generalPurpose",
		"FileSystemId": "fs-44205695",
		"NumberOfMountTargets": 0,
		"LifeCycleState": "creating",
		"OwnerId": "713367313056"
	}
-----------Get Subnets in your VPC where EC2 instances run. In my case all EKS instances run in private subnets.-----------
$ 	EKS_VPC_ID=$(aws eks describe-cluster --name $EKS_CLUSTER --query "cluster.resourcesVpcConfig.vpcId" --output text)
$ 	aws ec2 describe-subnets --filter Name=vpc-id,Values=$EKS_VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId'
	[
		"subnet-070fcb2a874ebff68"
	]
-----------Create Mount Targets-----------
# File system ID
$	EFS_ID="fs-44205695"


# Create mount targets for the subnets - Three subnets in my case
$	for subnet in subnet-070fcb2a874ebff68; do
	  aws efs create-mount-target \
		--file-system-id $EFS_ID \
		--security-group  $SG_ID \
		--subnet-id $subnet \
		--region ap-south-1
	done
# Output

	{
		"MountTargetId": "fsmt-80d87851",
		"VpcId": "vpc-056802fa887b47aaa",
		"AvailabilityZoneId": "aps1-az3",
		"NetworkInterfaceId": "eni-098717812a143962f",
		"FileSystemId": "fs-44205695",
		"AvailabilityZoneName": "ap-south-1b",
		"LifeCycleState": "creating",
		"SubnetId": "subnet-070fcb2a874ebff68",
		"OwnerId": "713367313056",
		"IpAddress": "10.0.0.20"
	}

-----------Deploy EFS CSI provisioner.-----------

$	kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/dev/?ref=master"

-----------List available CSI drivers:-----------

kubectl get csidrivers.storage.k8s.io

-----------Get FS ID to enter in PV-----------
$	aws efs describe-file-systems --query "FileSystems[*].FileSystemId"

-----------Apply Storageclass File-----------
$	kubectl apply -f - <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
EOF
-----------Apply PV-----------
$	vim efs-pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-pv
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: efs-sc
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-44205695 # Your EFS file system ID
-----------------------------