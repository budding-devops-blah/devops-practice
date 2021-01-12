# Create a PSQL DB server and restore DB from another master.

## Inventory File Explanation

* Below is for making Ansible use private key instead of User Name and Password. Mention your path where the file is stored.
```yaml
ansible_ssh_private_key_file
```
* Below is for making Ansible use python3 module since lookup uses boto3 and botocore plugins.
```yaml
ansible_python_interpreter=/usr/bin/python3
```

### It is not advisible to store password in the playbook, hence encrypt it with ansible-vault by entering below command 
Or
### Use AWS Secret Manager to store the password and lookup in Ansible.

* ## Using AWS Secret Manager
   * Make sure AWS CLI is configured in your Ansible Master.
   * Create a Secret in AWS Secret Manager and mention the type of secret.
```bash
aws secretsmanager create-secret --name psql_db_user_password --description "psql_db_user_password" --secret-string Passw0rd
```
   - Make note of the secret name "psql_db_user_password" in my case and enter the same in your task.

```yaml
password: "{{ lookup('aws_secret', 'psql_db_user_password') }}"
```


* ## Using Ansible Vault

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

## creating MySQL Dump of "employee_db" DB. (The same steps for PSQL also)

```yaml
- name: create a backup
        mysql_db:
          name: {{ db_name }}
          state: dump
          target: /home/sam/mysql_dump.sql
```

## In below task im using sync module and delegating to Slaves to pull the backup dump.

```yaml
- name: copy to slaves
        synchronize:
           src: /home/sam/mysql_dump.sql
           dest: /home/sam/scripts/
           mode: pull
        delegate_to: '{{ groups.db_slaves[0] }}'
```

## Creating SQL DB by executing below task.

```yaml
     - name: create mysql database
        mysql_db: 
            name: {{ db_name }}
            state: present
```

## Restoring the DB Dump by delegating to Slaves
```yaml
 - name: Restore the database
        mysql_db:
          name: {{ db_name }}
          state: import
          target: /home/sam/scripts/mysql_dump.sql
        delegate_to: '{{ groups.db_slaves[0] }}'
```		