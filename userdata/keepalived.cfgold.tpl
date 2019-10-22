global_defs {
   router_id ocp_vrrp
}
 
vrrp_script haproxy_check {
   script "/bin/kill -0 `cat /var/run/haproxy/haproxy.pid`"
   interval 2
   weight 2
}
 
vrrp_instance VI_1 {
   interface ens3
   virtual_router_id 133
   priority  100
   advert_int 2
   state  BACKUP
   
   unicast_src_ip ${ip0}

   unicast_peer {
     ${ip1}
     ${ip2}
   }
   track_script {
       haproxy_check
   }
   authentication {
      auth_type PASS
      auth_pass 1ce24b6e
   }
  notify_master "/usr/libexec/keepalived/ip_failover.sh" root
  notify_backup "/usr/libexec/keepalived/ip_release.sh" root
}