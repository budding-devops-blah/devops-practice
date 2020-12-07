--------Install Zalenium With Helm-------

Make sure you have helm installed.

--------Install with local charts-------
----------------------------------------
$	helm install <heml_release_name> --namespace <your_namespace> .

--------list your heml charts with below command----------
$	helm ls --namespace=<your_namespace>
----------------------------------------
--------Install with remote charts-------
$	helm repo add zalenium-github https://raw.githubusercontent.com/zalando/zalenium/master/charts/zalenium
$	helm install <heml_release_name> --namespace <your_namespace> zalenium-github/zalenium

--------Access your Zalenium pages from below URLs----------

$	http://<NodeIP>:<NodePort>/dashboard/
$	http://<NodeIP>:<NodePort>/grid/admin/live
$	http://<NodeIP>:<NodePort>/grid/console

Insteract with your Zalenium console using VNC with "Interact via VNC"