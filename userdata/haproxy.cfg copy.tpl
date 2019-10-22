global
    maxconn 100000
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
  
defaults
    mode               tcp
    log                global
    retries            2
    timeout queue      5s
    timeout connect    5s
    timeout client     60m
    timeout server     60m
    timeout check      15s
     
listen stats
    mode http
    bind ${ip0}:7000
    stats enable
    stats uri /
 
listen master
    bind ${vip}:5000
    maxconn 10000
    option tcplog
    option httpchk OPTIONS /master
    http-check expect status 200
    default-server inter 3s fastinter 1s fall 3 rise 4 on-marked-down shutdown-sessions
 server ${pgsql_hostname_prefix}1 ${ip0}:${pgbouncer_listen_port} check port 8008
 server ${pgsql_hostname_prefix}2 ${ip1}:${pgbouncer_listen_port} check port 8008
 server ${pgsql_hostname_prefix}3 ${ip2}:${pgbouncer_listen_port} check port 8008


listen replicas
    bind ${vip}:5001
    maxconn 10000
    option tcplog
    option httpchk OPTIONS /replica
    balance roundrobin
    http-check expect status 200
    default-server inter 3s fastinter 1s fall 3 rise 2 on-marked-down shutdown-sessions
 server ${pgsql_hostname_prefix}1 ${ip0}:${pgbouncer_listen_port} check port 8008
 server ${pgsql_hostname_prefix}2 ${ip1}:${pgbouncer_listen_port} check port 8008
 server ${pgsql_hostname_prefix}3 ${ip2}:${pgbouncer_listen_port} check port 8008


listen replicas_sync
    bind ${vip}:5002
    maxconn 10000
    option tcplog
    option httpchk OPTIONS /sync
    balance roundrobin
    http-check expect status 200
    default-server inter 3s fastinter 1s fall 3 rise 2 on-marked-down shutdown-sessions
 server ${pgsql_hostname_prefix}1 ${ip0}:${pgbouncer_listen_port} check port 8008
 server ${pgsql_hostname_prefix}2 ${ip1}:${pgbouncer_listen_port} check port 8008
 server ${pgsql_hostname_prefix}3 ${ip2}:${pgbouncer_listen_port} check port 8008


listen replicas_async
    bind ${vip}:5003
    maxconn 10000
    option tcplog
    option httpchk OPTIONS /async
    balance roundrobin
    http-check expect status 200
    default-server inter 3s fastinter 1s fall 3 rise 2 on-marked-down shutdown-sessions
 server ${pgsql_hostname_prefix}1 ${ip0}:${pgbouncer_listen_port} check port 8008
 server ${pgsql_hostname_prefix}2 ${ip1}:${pgbouncer_listen_port} check port 8008
 server ${pgsql_hostname_prefix}3 ${ip2}:${pgbouncer_listen_port} check port 8008