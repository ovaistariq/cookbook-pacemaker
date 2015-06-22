#
# Author:: Ovais Tariq <me@ovaistariq.net>
# Cookbook Name:: pacemaker_test
# Recipe:: default
#
# Copyright 2015, Ovais Tariq
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Do base corosync and pacemaker cluser setup and configuration
include_recipe "pacemaker::default"

# Setup haproxy
include_recipe "pacemaker_test::haproxy"

# Setup the cluster VIP on the founder pacemaker node
pacemaker_primitive "cluster_vip" do
  agent node["pacemaker_test"]["virtual_ip"]["agent"]
  params ({
    "ip" => node["pacemaker_test"]["cluster_vip"],
    "cidr_netmask" => 24
  })
  op node["pacemaker_test"]["virtual_ip"]["op"]
  action :create
  only_if { node[:pacemaker][:founder] }
end

# Setup the haproxy privimite on the founder pacemaker node
pacemaker_primitive "haproxy" do
  agent node["pacemaker_test"]["haproxy"]["agent"]
  op node["pacemaker_test"]["haproxy"]["op"]
  action :create
  only_if { node[:pacemaker][:founder] }
end

# We colocate cluster_vip and haproxy resources so that both the resources
# are started on the same node, otherwise Pacemaker will balance the different
# resources between different nodes
pacemaker_colocation "haproxy-cluster_vip" do
  resources "haproxy cluster_vip"
  score "INFINITY"
  only_if { node[:pacemaker][:founder] }
end

# We configure the order of resources so that any action taken on the resources
# cluster_vip and haproxy are taken in order
pacemaker_order "haproxy-after-cluster_vip" do
  ordering "cluster_vip haproxy"
  score "mandatory"
  only_if { node[:pacemaker][:founder] }
end
