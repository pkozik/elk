# elk sandbox



On IA:
===============
[root@pkozik-dev-lab external_images]# pwd
/software_repository/external_images

-rw-r--r--. 1 cloud-user cloud-user 410358392 Jul  6 14:10 csf_elk_e_TAG_5.4.tar.gz
-rw-r--r--. 1 cloud-user cloud-user 416585207 Jul  6 14:26 csf_elk_k_TAG_5.4.tar.gz
-rw-r--r--. 1 cloud-user cloud-user 448476357 Jul  6 14:26 csf_elk_l_TAG_5.4.tar.gz


On Admin
===============

[admin@ee3bb9c5ec86 ~]$ registry add csf/elk_e:5.4


Odinstalowac EK, L zostaje
==============================
ansible-playbook -e @security.yml --tags=elasticsearch -e 'elasticsearch_uninstall=true' addons/elk.yml
ansible-playbook -e @security.yml -e 'kibana_uninstall=true' addons/kibana.yml


Install new ELK
===============

cd /opt/rapport/plat/mantl
curl -O $LOCALHOST_IP/external_images/elk.5.4.tgz
tar zxvf elk.5.4.tgz

ansible-playbook -e @security.yml elk.5.4/playbooks/prepare.yml
ansible-playbook -e @security.yml elk.5.4/playbooks/install.yml


Verify
===========
[admin@ee3bb9c5ec86 mantl]$ plat-manager services checks --id service:elasticsearch*
