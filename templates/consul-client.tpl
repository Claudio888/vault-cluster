{
  "server": false,
  "node_name": "vault-${index}",
  "datacenter": "dc1",
  "data_dir": "/var/lib/consul/data",
  "bind_addr": "${vault_address}",
  "client_addr": "127.0.0.1",
  "retry_join": ["${consul_address1}", "${consul_address2}", "${consul_address3}"],
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8" : false
}