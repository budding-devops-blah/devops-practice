# Create a PSQL DB server and restore DB from another master.

### It is not advisible to store password in the playbook, hence encrypt it with ansible-vault by entering below command

```bash
ansible-vault encrypt <playbook_yaml_file>
-------------------------------------------
ansible-vault encrypt psql_create_db.yaml
```

## To View/Edit the content of the playbook, view by entering below command
```bash
ansible-vault view <playbook_yaml_file>
---------------------------------------
ansible-vault view psql_create_db.yaml

ansible-vault edit <playbook_yaml_file>
---------------------------------------
ansible-vault edit psql_create_db.yaml
```


## To run the playbook, enter below command to ask for vault password
```bash
ansible-playbook -i <inventory_file> <playbook_yaml_file> --ask-vault-pass
ansible-playbook -i psql.txt psql_create_db.yaml --ask-vault-pass
```