# Copyright 2011, Dell, Inc.
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

case node["platform_family"]
when 'suse'
  default["pacemaker"]["platform"]["packages"] = %w(pacemaker crmsh)

  # pacemaker-mgmt-client provides hb_gui, which it's useful
  # to run over ssh.  Note that pacemaker-mgmt needs to be installed
  # *before* the openais service is started, otherwise the mgmtd
  # plugin won't be forked as a child process.
  default["pacemaker"]["platform"]["graphical_packages"] = %w(
    pacemaker-mgmt pacemaker-mgmt-client
    xorg-x11-xauth xorg-x11-fonts
  )
  default["pacemaker"]["platform"]["crm_package"] = nil
when 'rhel'
  default["pacemaker"]["platform"]["packages"] = %w(pacemaker)
  default["pacemaker"]["platform"]["crm_package"] = "crmsh"
  default["pacemaker"]["platform"]["graphical_packages"] = nil
  default["pacemaker"]["platform"]["service_name"] = "pacemaker"
end

default["pacemaker"]["founder"] = false
default["pacemaker"]["crm"]["initial_config_file"] = "/etc/corosync/crm-initial.conf"

# We ignore the quorum by default, this is needed for a 2 node cluster
# as both the nodes go down in case of them is down as the remaining one will
# also loose quorum
default["pacemaker"]["crm"]["no_quorum_policy"] = "ignore"

# Default timeout for operations in seconds
default["pacemaker"]["crm"]["op_default_timeout"] = 60

# Don't setup/configure heartbeat GUI
default["pacemaker"]["setup_hb_gui"] = false

# stonith is disabled by default
# Values can be "disabled", "manual", "sbd", "shared", "per_node"
default["pacemaker"]["stonith"]["mode"] = "disabled"

# This hash will contain devices for each node.
# For instance:
#  default[:pacemaker][:stonith][:sbd][:nodes][$node][:devices] = ['/dev/disk/by-id/foo-part1', '/dev/disk/by-id/bar-part1']
default["pacemaker"]["stonith"]["sbd"]["nodes"] = {}

default["pacemaker"]["stonith"]["shared"]["agent"] = ""
# This can be either a string (containing a list of parameters) or a hash.
# For instance:
#   default[:pacemaker][:stonith][:shared][:params] = 'hostname="foo" password="bar"'
# will give the same result as:
#   default[:pacemaker][:stonith][:shared][:params] = {"hostname" => "foo", "password" => "bar"}
default["pacemaker"]["stonith"]["shared"]["params"] = {}

default["pacemaker"]["stonith"]["per_node"]["agent"] = ""
# This can be "all" or "self":
#   - if set to "all", then every node will configure the stonith resources for
#     all nodes in the cluster
#   - if set to "self", then every node will configure the stonith resource for
#     itself only
default["pacemaker"]["stonith"]["per_node"]["mode"] = "all"
# This hash will contain parameters for each node. See documentation for
# default[:pacemaker][:stonith][:shared][:params] about the format.
# For instance:
#  default[:pacemaker][:stonith][:per_node][:nodes][$node][:params] = 'hostname="foo" password="bar"'
default["pacemaker"]["stonith"]["per_node"]["nodes"] = {}

default["pacemaker"]["notifications"]["agent"] = "ocf:heartbeat:ClusterMon"
default["pacemaker"]["notifications"]["smtp"]["enabled"] = false
default["pacemaker"]["notifications"]["smtp"]["to"] = ""
default["pacemaker"]["notifications"]["smtp"]["from"] = ""
default["pacemaker"]["notifications"]["smtp"]["server"] = ""
default["pacemaker"]["notifications"]["smtp"]["prefix"] = ""
