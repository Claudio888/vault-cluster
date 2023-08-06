{
  "server": true,
  "node_name": "consul-${index}",
  "datacenter": "dc1",
  "data_dir": "/var/lib/consul/data",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr":"${consul_address}",
  "bootstrap_expect": 3,
  "retry_join": ["${consul_address1}", "${consul_address2}", "${consul_address3}"],
  "ui": true,
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8" : false
}