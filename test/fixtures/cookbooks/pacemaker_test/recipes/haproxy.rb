#
# Author:: Ovais Tariq <me@ovaistariq.net>
# Cookbook Name:: pacemaker_test
# Recipe:: haproxy
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

# Do base setup common to all the machines
include_recipe "haproxy::default"

# HAProxy configuration begins here
include_recipe "haproxy::install_#{node['haproxy']['install_method']}"

cookbook_file "/etc/default/haproxy" do
  source "haproxy-default"
  cookbook "haproxy"
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[haproxy]"
end


if node['haproxy']['enable_admin']
  admin = node['haproxy']['admin']
  haproxy_lb "admin" do
    bind "0.0.0.0:22002"
    mode 'http'
    params(admin['options'])
  end
end

conf = node['haproxy']
member_max_conn = conf['member_max_connections']
member_weight = conf['member_weight']

haproxy_lb "pacemaker_test_lb" do
  type "listen"
  servers ["node1 127.0.0.1:8080 check inter 10s rise 2 fall 3"]
  balance "roundrobin"
  bind "0.0.0.0:80"
  mode "http"
end


# Re-default user/group to account for role/recipe overrides
node.default['haproxy']['stats_socket_user'] = node['haproxy']['user']
node.default['haproxy']['stats_socket_group'] = node['haproxy']['group']

unless node['haproxy']['global_options'].is_a?(Hash)
  Chef::Log.error("Global options needs to be a Hash of the format: { 'option' => 'value' }. Please set node['haproxy']['global_options'] accordingly.")
end

template "#{node['haproxy']['conf_dir']}/haproxy.cfg" do
  source "haproxy.cfg.erb"
  cookbook "haproxy"
  owner "root"
  group "root"
  mode 00644
  notifies :reload, "service[haproxy]"
  variables(
    :defaults_options => node["haproxy"]["defaults_options"],
    :defaults_timeouts => node["haproxy"]["defaults_timeouts"]
  )
end

service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action :nothing
end
