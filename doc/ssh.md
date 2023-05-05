# Getting SSH access

See [special access to buildresources](./process/special_access_to_build_resources.md)
for the detailed policy on access to machines.

If you are not a member of the build working group, open an issue in
the build repo for temporary SSH keys. The following instructions are
for build working group members.

1. If you have not added your public keys in the [secrets repo][],
   follow the instructions there to gain access to the credentials.
2. Copy the SSH keys in the [secrets repo][] to your `~/.ssh` folder. What keys
   are available to you depends on the roles you have. In order to create new
   vm's and hook them up to CI you have to be part of the `infra` group.
   See [resources](./resources.md) for details about the groups.
   To protect the unencrypted private keys, you can use
   `ssh-keygen -p -f ~/.ssh/name_of_private_key` to add a personal passphrase to
   the local copy of the key.
3. Add this section to your `~/.ssh/config` file (if this file does not exist,
   create one). The configuration for the hosts will be written between the
   comments:

    ```
    # begin: node.js template

    # end: node.js template
    ```
4. Follow the instructions in the [ansible guide](../ansible/README.md) to
   install ansible on your local machine.
5. Run `ansible-playbook ansible/playbooks/write-ssh-config.yml` from the root of this repo, 
   then the host information will be
   written into your `~/.ssh/config`.  If you got here from the top-level
   README.md, you get to this step before getting to the Secrets section, go
   do that setup. You may get an ERROR, but all the playbook commands  were run,
   check your `~/.ssh/config` to ensure it was updated with the names of all
   the machines from inventory.yml. Example "error":
```
[DEPRECATION WARNING]: DEFAULT_SQUASH_ACTIONS option, Loop squashing is
deprecated and
 this configuration will no longer be used , use a list directly with the module
 argument instead. This feature will be removed in version 2.11. Deprecation
 warnings
 can be disabled by setting deprecation_warnings=False in ansible.cfg.
  [ERROR]: WARNING: could not find secrets, please define NODE_BUILD_SECRETS
```
6. Try logging into one of the machines that you have access to. In the
   `~/.ssh/config` file, the first word in the `Host` indicates the group
   that the machine is in, and the `IdentityFile` for each host can be
   found in the corresponding folder for the group in the [secrets repo][].
   All build working group members can have access to the machines in the
   `test` group, so for example, you should be able to log into
   `test-digitalocean-ubuntu1604-x86-1` by running
   `ssh test-digitalocean-ubuntu1604-x86-1` directly.

If everything is set up correctly, you should be able to log into
the machine without passwords. By default you will log into the machine
as `root` (or a sudoer user),
but it is recommended to switch to the `iojs` user (run `su - iojs` or
`sudo su - iojs` for non-root logins) before performing any actions.

[secrets repo]: https://github.com/nodejs-private/secrets
