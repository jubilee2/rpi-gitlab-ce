# Docker options
## Prevent Postgres from trying to allocate 25% of total memory
postgresql['shared_buffers'] = '1MB'

# Disable Prometheus node_exporter inside Docker.
node_exporter['enable'] = false

# Manage accounts with docker
manage_accounts['enable'] = false

# Get hostname from shell
host = `hostname`.strip
external_url "http://#{host}"

# Explicitly disable init detection since we are running on a container
package['detect_init'] = false

# Load custom config from environment variable: GITLAB_OMNIBUS_CONFIG
# Disabling the cop since rubocop considers using eval to be security risk but
# we don't have an easy way out, atleast yet.
eval ENV["GITLAB_OMNIBUS_CONFIG"].to_s # rubocop:disable Security/Eval

# Load configuration stored in /etc/gitlab/gitlab.rb
from_file("/etc/gitlab/gitlab.rb")

###! Minimum worker_processes is 2 at this moment
###! See https://docs.gitlab.com/omnibus/settings/rpi.html
# Reduce the number of running workers to the minimum in order to reduce memory usage
unicorn['worker_processes'] = 2
sidekiq['concurrency'] = 9

# Turn off monitoring to reduce idle cpu and disk usage
prometheus_monitoring['enable'] = false