#https://stackoverflow.com/questions/37333305/ansible-create-a-user-with-sudo-privileges
---
- name: runtime public playbook
  hosts: runtime_public_nodes
  remote_user: ec2-user
  become: true
  tasks:
    - name: Make sure we have a 'wheel' group
      group:
        name: wheel
        state: present

    - name: Allow 'wheel' group to have passwordless sudo
      lineinfile:
        dest: /etc/sudoers
        state: present
        regexp: '^%wheel'
        line: '%wheel ALL=(ALL) NOPASSWD: ALL'
        validate: 'visudo -cf %s'

    - name: Add the user 'bluedata'
      ansible.builtin.user:
        name: bluedata
        comment: bluedata
        shell: /bin/bash
        uid: 1040
        groups: users, admin, shadow, wheel
        group: bdcs #primary group

    #fs_setup:
    #  - label: opt
    #    filesystem: ext4
    #    device: /dev/xvdz 
    #    partition: auto

    - name: filesystem setup
      filesystem:
        fstype: ext4
        dev: /dev/xvdz

    #mounts:
    # - [ "/dev/xvdz", "/opt", "ext4", "defaults", "0", "2" ]
    - name: mount
      path: /opt
      src: /dev/xvdz
      fstype: ext4

    - name: upgrade all packages
      yum: name=* state=latest

    - name: Download Exmeral Platform
      ansible.builtin.command: curl -L -o /var/www/html/hpe-cp-rhel-release-5.4.1-3073.bin https://ezmeral-platform-releases.s3.amazonaws.com/5.4.1/3073/hpe-cp-rhel-release-5.4.1-3073.bin

    - name: Make Exmeral Platform binary executable
      ansible.builtin.command: chmod u+x ./hpe-cp-rhel-release-5.4-3064.bin

---
- hosts: runtime_worker_nodes
  roles:
    - common
    - webservers