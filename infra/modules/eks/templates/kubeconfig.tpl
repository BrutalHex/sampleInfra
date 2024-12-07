apiVersion: v1
kind: Config
clusters:
- name: "${cluster_name}"
  cluster:
    server: "${cluster_endpoint}"
    certificate-authority-data: "${cluster_ca_certificate}"
contexts:
- name: "${cluster_name}"
  context:
    cluster: "${cluster_name}"
    user: "${cluster_name}"
users:
- name: "${cluster_name}"
  user:
    token: "${cluster_auth_token}"
current-context: "${cluster_name}"