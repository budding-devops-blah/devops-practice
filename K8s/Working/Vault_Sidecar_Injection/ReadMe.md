# HashiCorp Vault secret Injection with Side Car 

### Advantages

* By eliminating native methods of using Kubernetes Secrets for storing a key-value pair, we are going to use HashiCorp Vault to store the Key-Value and inject the same into main container.
* With this method, we can also create temporary creds for the lifecycle of the container alone, so that when the pod dies, the credentials created for it also dies.

## Install the Vault Helm chart

#### Add the HashiCorp Helm repository.

``` bash
helm repo add hashicorp https://helm.releases.hashicorp.com
```

#### Install the latest version of the Vault server running in development mode.

``` bash
helm install vault hashicorp/vault --set "server.dev.enabled=true" --set 'server.extraArgs="-dev-listen-address=0.0.0.0:8200"'

```
 > Here we are mentioning dev-listen-address as 0.0.0.0 else the listen address would be 127.0.0.1 and Pods won't be able to reach vault.

##### There are three methods by which vault can be initialised, 
* #### Dev 
> For local development where the vault will be completely un-sealed and you can access the vault if you have access to the cluster.
* #### Standalone 
> Vault will be sealed by providing 5 keys and 1 access token, to access the vault, we got to unseal the sealed vault, 3 keys should be provided to unseal the vault and to access the vault UI, we will be needing the access token.
``` bash
$ vault operator unseal
Key (will be hidden):
```
* #### HA
> This is used for production where multiple pods of vault will be running, so when one Pod dies, we don't have to re-initialize and un-seal the vault. 
### Post installation with Helm.
The Vault pod and Vault Agent Injector pod are deployed in the default namespace.

Display all the pods within the default namespace.

``` bash
kubectl get pods
```

You can see there will be two Pods initialised, one being Vault and another Vault-Injector
``` bash
$ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          80s
vault-agent-injector-5945fb98b5-tpglz   1/1     Running   0          80s
```
The vault-0 pod runs a Vault server in development mode. The vault-agent-injector pod performs the injection based on the annotations present or patched on a deployment.

### Set a secret in Vault

The applications that you deploy in the Inject secrets into the pod section expect Vault to store a username and password stored at the path internal/database/config. To create this secret requires that a key-value secret engine is enabled and a username and password is put at the specified path.

Start an interactive shell session on the vault-0 pod.

```bash
kubectl exec -it vault-0 -- /bin/sh
```
Once you are logged into Vault container, enable "kv-v2" secrets at the path internal

```bash
vault secrets enable -path=internal kv-v2
```
Create a secret at path internal/database/config with a username and password.
```bash
$ vault kv put internal/database/config username="db-readonly-username" password="db-secret-password"
Key              Value
---              -----
created_time     2020-03-25T19:03:57.127711644Z
deletion_time    n/a
destroyed        false
version          1
```
Verify that the secret is defined at the path internal/database/config.

```bash
$ vault kv get internal/database/config
====== Metadata ======
Key              Value
---              -----
created_time     2020-03-25T19:03:57.127711644Z
deletion_time    n/a
destroyed        false
version          1

====== Data ======
Key         Value
---         -----
password    db-secret-password
username    db-readonly-username
```
The secret is ready for the application.

### Configure Kubernetes authentication.
Vault provides a Kubernetes authentication method that enables clients to authenticate with a Kubernetes Service Account Token. This token is provided to each pod when it is created.

Start an interactive shell session on the vault-0 pod.
```bash
$ kubectl exec -it vault-0 -- /bin/sh
```
Enable the Kubernetes authentication method.

```bash
$ vault auth enable kubernetes
```
Vault accepts this service token from any client within the Kubernetes cluster. During authentication, Vault verifies that the service account token is valid by querying a configured Kubernetes endpoint.

Configure the Kubernetes authentication method to use the service account token, the location of the Kubernetes host, and its certificate.

```bash
$ vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```
The token_reviewer_jwt and kubernetes_ca_cert are mounted to the container by Kubernetes when it is created. The environment variable KUBERNETES_PORT_443_TCP_ADDR is defined and references the internal network address of the Kubernetes host.

For a client to read the secret data defined at internal/database/config, requires that the read capability be granted for the path internal/data/database/config. A policy defines a set of capabilities.

Write out the policy named internal-app that enables the read capability for secrets at path internal/data/database/config.

```bash
$ vault policy write internal-app - <<EOF
path "internal/data/database/config" {
  capabilities = ["read"]
}
EOF
```
Create a Kubernetes authentication role named internal-app.
```bash
$ vault write auth/kubernetes/role/internal-app \
    bound_service_account_names=internal-app \
    bound_service_account_namespaces=default \
    policies=internal-app \
    ttl=24h
```

The role connects the Kubernetes service account, internal-app, and namespace, default, with the Vault policy, internal-app. The tokens returned after authentication are valid for 24 hours.

Lastly, exit the vault-0 pod.
```bash
$ exit
```
#### Define a Kubernetes service account
The Vault Kubernetes authentication role defined a Kubernetes service account named internal-app. This service account does not yet exist by default and we will have to create with below command.

```bash
cat  <<'EOF' >> service-account-internal-app.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: internal-app
EOF
```
This definition of the service account creates the account with the name `internal-app`.

Apply the service account definition to create it.
```bash
$ kubectl apply --filename service-account-internal-app.yml
```
Verify that the service account has been created.

```bash
$ kubectl get serviceaccounts
```
The name of the `service account` here aligns with the name assigned to the `bound_service_account_names` field when the internal-app role was created.

> ` bound_service_account_names=internal-app`

### Application to access the Vault KV
Create a deployment file,

```bash
$ cat <<'EOF' >> deployment-orgchart.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orgchart
  labels:
    app: orgchart
spec:
  selector:
    matchLabels:
      app: orgchart
  replicas: 1
  template:
    metadata:
      annotations:
      labels:
        app: orgchart
    spec:
      serviceAccountName: internal-app
      containers:
        - name: orgchart
          image: jweissig/app:0.0.1
EOF
```
The name of this deployment is ``orgchart``. The `spec.template.spec.serviceAccountName` defines the service account internal-app to run this container.

Apply the deployment defined in `deployment-orgchart.yml`.

```bash
$ kubectl apply --filename deployment-orgchart.yml
```
The `orgchart` pod within the `default namespace`.

Get all the pods within the `default` namespace.
```bash
$ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
orgchart-69697d9598-l878s               1/1     Running   0          18s
vault-0                                 1/1     Running   0          58m
vault-agent-injector-5945fb98b5-tpglz   1/1     Running   0          58m
```
The Vault-Agent injector looks for deployments that define specific `annotations`. None of these annotations exist within the current deployment since we have not added those. 

This`ls: /vault/secrets: No such file or directory
command terminated with exit code 1` means that no secrets are present on the orgchart container within the orgchart pod.
```bash
$ kubectl exec \
    $(kubectl get pod -l app=orgchart -o jsonpath="{.items[0].metadata.name}") \
    --container orgchart -- ls /vault/secrets
ls: /vault/secrets: No such file or directory
command terminated with exit code 1
```
### Inject secrets into the pod

```bash
$ cat <<'EOF' >>  patch-inject-secrets.yml
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "internal-app"
        vault.hashicorp.com/agent-inject-secret-database-config.txt: "internal/data/database/config"
EOF
```
These annotations define a partial structure of the deployment schema and are prefixed with vault.hashicorp.com.

`agent-inject` enables the Vault Agent Injector service.

`role` is the Vault Kubernetes authentication role

`agent-inject-secret-FILEPATH` prefixes the path of the file, database-config.txt written to the /vault/secrets directory. The value is the path to the secret defined in Vault.

Patch the `orgchart` deployment defined in `patch-inject-secrets.yml`.
```bash
$ kubectl patch deployment orgchart --patch "$(cat patch-inject-secrets.yml)"
```
A new `orgchart` pod starts alongside the existing pod. When it is ready the original terminates and removes itself from the list of active pods.
```bash
$ kubectl get pods
NAME                                    READY   STATUS     RESTARTS   AGE
orgchart-599cb74d9c-s8hhm               0/2     Init:0/1   0          23s
orgchart-69697d9598-l878s               1/1     Running    0          20m
vault-0                                 1/1     Running    0          78m
vault-agent-injector-5945fb98b5-tpglz   1/1     Running    0          78m
```
This new pod now launches two containers. The application container, named `orgchart`, and the Vault Agent container, named `vault-agent`.

Display the logs of the `vault-agent` container in the new `orgchart` pod.
```bash
$ kubectl logs \
    $(kubectl get pod -l app=orgchart -o jsonpath="{.items[0].metadata.name}") \
    --container vault-agent
```
Finally, display the secret written to the orgchart container in the orgchart pod.
```bash
$ kubectl exec \
    $(kubectl get pod -l app=orgchart -o jsonpath="{.items[0].metadata.name}") \
    -c orgchart -- cat /vault/secrets/database-config.txt
```
Output would be `postgresql://db-readonly-user:db-secret-password@postgres:5432/wizard`

The secrets are rendered in a PostgreSQL connection string is present on the container.

* ##### References
> https://www.youtube.com/watch?v=jEUyKjEatWg
> https://www.hashicorp.com/blog/injecting-vault-secrets-into-kubernetes-pods-via-a-sidecar
> https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar