#######https://medium.com/@arun.gowda/securing-aws-elasticsearch-service-by-cognito-authentication-f4cd1ff7953c#######
--------Use AWS Elastic Search Service with Cognito Auth-------
--------Setting up User Pool-------
#####Userpool is for managing users and groups. Inside User pool, we create users and add those users to Groups

1. Open the AWS Management Console and sign in.

2. Go to the services section and type Cognito, you will get an option for Amazon Cognito, click on that and you will get a welcome dashboard for Amazon cognito.

3. click on Manage User Pools section.

4.Click on Create a user pool on top left section.

5.Give the user pool a name. In this example, I named my pool "ELK_Kibana_Access". You can step through the settings or choose the defaults. For now, choose Review defaults.

6.click on attributes section which is on the top left section of the page.

7.Verify that username option is checked and in standard attribute section email is checked.

8.Once done click on the review section and click on create pool.

9.Click on domain name section on the left .Type a name in the text box. In this example, I used "elk-kibana". Be sure to choose Save changes.

10. Make a note of Pool ID, we need those details again when we shall be creating the user identity pool.

11. Create a user in userpool under "Users and groups" option and this is the user with which we will be able to login into Kibana endpoint

--------Setting up Identity Pool-------
########Identity pool is to give level of access to our user pool
1. Give your identity pool a name. I chose "ELK_Kibana_Access". Then select the Enable access to unauthenticated identities check box.

2. Now in below list of Auth providers, choose Cognito and paste the Userpool's User Pool ID and APP Client ID

3. Post creating you will be redirected to IAM for creating a role. Just click OK at IAM page since all necessary roles are autofilled.

--------Setting up Elastic and Kibana-------
1. Open EES and selet type of deployment

2. Enter ElasticSearch Domain Name

3. Select "Custom endpoint" if you want a custom URL endpoint with SSL Cert.

4. Select instance types and other common config. such as instance types, storage, Master Node, VPC 

5. Select "Amazon Cognito authentication" and select the Cognito Userpool and Identity Pool.

6. Under Access Policy select "Custom Access Policy" and choose IAM as element with IAM Role created for Cognito's arn being entered at Principal.

7. Once the Elastic Search is ready, we will not be able to access it outside our VPC, hence access the Kibana endpoint "https://vpc-elk-kibana-afzwwcw5fnidvncijnelitzbzu.ap-south-1.es.amazonaws.com/_plugin/kibana/" from a   instance which is present in your same VPC.

8. At first login, password change will be asked post which we will be able to login into Kibana with Cognito Userpool

-----------------------Setup FluentD for external ElasticSearch--------------
#####Fluentd can't directly communicate with Elasticsearch eventhough it's in same VPC, so we use es-proxy for communication. Hence we are deploing the same.
#####Spin up EKS in same VPC as that of Elasticsearch or we will be needing VPCPeer to send data from FluentD to Elasticsearch.
----Create namespace----
$	kubectl create namespace kube-elk

----initialize helm----

$ helm init

----Edit your secret, access and endpoint in :es-proxy-deploy.yaml" deployment file----

$     - image: gcr.io/learning-containers-187204/vke-es-proxy #built using a go based es-proxy
        name: es-proxy
        env:        
        - name: AWS_ACCESS_KEY_ID
          value: "<AWS_Access_Key>"
        - name: AWS_SECRET_ACCESS_KEY
          value: "<AWS_Secret_key>"
        - name: ES_ENDPOINT
          value: "https://vpc-elk-kibana-afzwwcw5fnidvncijnelitzbzu.ap-south-1.es.amazonaws.com/_plugin/kibana/"
        volumeMounts:
		
$	kubectl create -f es-proxy-deploy.yaml
$	kubectl create -f es-proxy-service.yaml

$	helm install --name kube-elk-cogito -f values-es.yaml stable/fluentd-elasticsearch --namespace=kube-elk


Open elasticsearch and in discover tab we can see Fluentd sending all log data.
