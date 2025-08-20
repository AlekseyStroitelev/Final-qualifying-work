[all]
node1 ansible_host=${master_public_ip} ansible_user=ubuntu ip=${master_private_ip}
node2 ansible_host=${worker1_public_ip} ansible_user=ubuntu ip=${worker1_private_ip}
node3 ansible_host=${worker2_public_ip} ansible_user=ubuntu ip=${worker2_private_ip}

[kube_control_plane]
node1

[etcd]
node1

[kube_node]
node2
node3

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
