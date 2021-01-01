# Prometheus send alerts to email with helm


## Add Prometheus charts repo to Helm Repo and update it.

```bash
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo add stable https://charts.helm.sh/stable
$ helm repo update
```
## To access the application over internet, create "values.yaml"

```yaml
server:
  service:
    nodePort: 31000
    type: NodePort 
```
#### once values.yaml is ready, execute below command to install helm with NodePort service


```bash
$ helm install <release_name> prometheus-community/prometheus --values ./values.yaml
```

### Now we can access the prometheus application over internet by entering below url
```bash
nodeport:31000
```






























References


[https://boxboat.com/2019/08/08/monitoring-kubernetes-with-prometheus/](https://boxboat.com/2019/08/08/monitoring-kubernetes-with-prometheus/)

[https://stackoverflow.com/questions/54535869/use-prometheus-with-external-ip-address](https://stackoverflow.com/questions/54535869/use-prometheus-with-external-ip-address)

[https://medium.com/techno101/how-to-send-a-mail-using-prometheus-alertmanager-7e880a3676db](https://medium.com/techno101/how-to-send-a-mail-using-prometheus-alertmanager-7e880a3676db)

[https://artifacthub.io/packages/helm/prometheus-community/prometheus](https://artifacthub.io/packages/helm/prometheus-community/prometheus)

