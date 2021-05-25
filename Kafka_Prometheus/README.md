# Kafka Monitoring using Prometheus and alerting using Gmail Alert Manager

* Just clone the repo, enter your gmail password in `alertmanager.yml` and enter the below command, 
```bash
docker-compose up
```
* Grafana and Prometheus can be accessed on ports 3000 and 9090

#### Ref: 
> * https://github.com/Mousavi310/kafka-grafana - Kafka_Prometheus
> * https://github.com/alerta/prometheus-config - Alert Manager Docker Compose
> * https://github.com/cloudtechmasters/prometheus-alertmanager-grafana/blob/main/gmail-alertmanager.yml - Gmail Alert Manager
> * https://github.com/dcos/prometheus-alert-rules/blob/master/rules/kafka/kafka-rules.yml - Kafka Alert Rules
