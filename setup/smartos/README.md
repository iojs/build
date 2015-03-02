# io.js Build SmartOS Setup

Note that these hostnames are also used in the *[ansible-inventory](http://docs.ansible.com/intro_inventory.html)* file. 
The IP addresses will need to be updated each time the servers are reprovisioned.

To set up a host, run:

```text
$ ansible-playbook -i ../ansible-inventory ansible-playbook.yaml
```

**Users**: The ansible-vars.yaml file contains a list of users who's GitHub public keys are pulled and placed into 
authorized_keys for both root and iojs users. This file should be updates when new users are added to the build project 
who are able to help maintain the containerized builds.
