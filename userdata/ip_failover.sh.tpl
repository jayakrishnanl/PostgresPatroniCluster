#!/bin/bash

# This helper script runs to failover floating IP to newly elected Keepalived Primary node.

OCI=`which oci`

$OCI network vnic assign-private-ip  --vnic-id ${VNIC} --ip-address ${VIP}  --unassign-if-already-assigned --auth instance_principal

ip addr add ${VIP}/24 dev ens3:1 label ens3:1
