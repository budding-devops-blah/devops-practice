-------------------------------------------------------------------------
------Send K8s Logs to External Elastic search and visualize the same----

####Refer URL#####
https://computingforgeeks.com/ship-kubernetes-logs-to-external-elasticsearch/

------Install Elastic Search by below commands------
------Add Elastic Search to YUM Repo------
$	sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
$	sudo vi /etc/yum.repos.d/elasticsearch.repo
Add below lines
$	[elasticsearch-6.x]
	name=Elasticsearch repository for 6.x packages
	baseurl=https://artifacts.elastic.co/packages/6.x/yum
	gpgcheck=1
	gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
	enabled=1
	autorefresh=1
	type=rpm-md
------YUM install elasticsearch------	
$	sudo yum install elasticsearch
$	sudo vi /etc/elasticsearch/elasticsearch.yml

------Edit below property to 0.0.0.0 to be accessible over internet------
$	. . .
	network.host: 0.0.0.0
	. . .
$	sudo systemctl start elasticsearch	
$	sudo systemctl enable elasticsearch
------Check the output------
$	curl -X GET "<Server_IP>:9200"
------Install KIBANA to visualize the data------
$	sudo yum install kibana nginx
$	sudo systemctl enable kibana
$	sudo systemctl start kibana
------Create a username and passwd and save it in nginx/htpasswd------
$	echo "kibanaadmin:`openssl passwd -apr1`" | sudo tee -a /etc/nginx/htpasswd.users
------Now check Nginx config and restart-------
$	sudo nginx -t
$	sudo systemctl restart nginx
------Access KIBANA-------
http://<Server_IP>/status

-------ONCE Elastic Search and KIBANA are done, now it's time for Metricbeat and Filebeat install in K8s Cluster-------
-------Download Metric beat and Filebeat deploy files------
$	curl -L -O https://raw.githubusercontent.com/elastic/beats/7.9/deploy/kubernetes/filebeat-kubernetes.yaml
$	curl -L -O https://raw.githubusercontent.com/elastic/beats/7.9/deploy/kubernetes/metricbeat-kubernetes.yaml

-------Edit ELASTICSEARCH_HOST IP under Config Map and Pod ENV for both Metric Beat and Filebeat YML files-------
-----------Config Map-------------
$    output.elasticsearch:
      hosts: ['${ELASTICSEARCH_HOST:<Server_IP>}:${ELASTICSEARCH_PORT:9200}']
      #username: ${ELASTICSEARCH_USERNAME}
      #password: ${ELASTICSEARCH_PASSWORD}
-----------POD ENV-------------
$	env:
        - name: ELASTICSEARCH_HOST
          value: :52.66.208.97
        - name: ELASTICSEARCH_PORT
          value: "9200"

-------Edit spec for Pod if metricbeat and filebeat needs to run on MASTER node for MASTER node logs in both Metric Beat and Filebeat YML files-------
$	  # This toleration is to have the daemonset runnable on master nodes
      # Remove it if your masters can't run pods
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
------------------------------------------------------------------------------------------------		