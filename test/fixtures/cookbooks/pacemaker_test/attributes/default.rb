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

default["pacemaker_test"]["cluster_vip"] = "192.168.33.100"

default["haproxy"]["enable_default_http"] = false
default["haproxy"]["enable_stats_socket"] = true
default["haproxy"]["mode"] = "http"

default["pacemaker_test"]["virtual_ip"]["agent"] = "ocf:heartbeat:IPaddr2"
default["pacemaker_test"]["virtual_ip"]["op"]["monitor"]["interval"] = "30s"

default["pacemaker_test"]["haproxy"]["agent"] = "lsb:haproxy"
default["pacemaker_test"]["haproxy"]["op"]["monitor"]["interval"] = "10s"
