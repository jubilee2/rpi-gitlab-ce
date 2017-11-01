# Docker options
## Prevent Postgres from trying to allocate 25% of total memory
postgresql['shared_buffers'] = '1MB'

# Manage accounts with docker
manage_accounts['enable'] = false

# Get hostname from shell
host = `hostname`.strip
external_url "http://#{host}"

# Load custom config from environment variable: GITLAB_OMNIBUS_CONFIG
eval ENV["GITLAB_OMNIBUS_CONFIG"].to_s

# Load configuration stored in /etc/gitlab/gitlab.rb
from_file("/etc/gitlab/gitlab.rb")

###! Minimum worker_processes is 2 at this moment
###! See https://gitlab.com/gitlab-org/gitlab-ce/issues/18771
unicorn['worker_processes'] = 2
