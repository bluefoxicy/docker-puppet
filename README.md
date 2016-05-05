# Puppetlabs Dockerfiles

*Unofficial* Dockerfiles for Puppetlabs Puppet Collection releases.

These Docker images build on Ubuntu and Puppet Collection releases.
Ubuntu images roll up all updates, while CentOS images contain only
the package versions at time of installation DVD release.  Docker
Hub automatically triggers rebuilds on dependency rebuild, so these
images benefit from autobuild and automatic patching only when
based on Ubuntu.

## Configuration

Use `docker-compose` as provided by the `docker-compose.yml.example`
file.

### Volumes

Use the following volumes:

* `/etc/puppetlabs/puppet/ssl`: CA and Puppet agent certificates.
This must be writable.
* `/etc/puppetlabs/code`:  Environments.  This may be read-only.
* `/etc/puppetlabs/puppet/puppet.conf`:  Main puppet configuration.
If you tweak this by hand, _mount it read-only_.

### Environment variables

In the `environment` section in docker-compose.yml, you can use the
following.

#### puppetserver

* *PUPPETSERVER_HOSTNAME*: Overrides the hostname.  Defaults to the
container's FQDN.
* *PUPPETSERVER_CERTNAME*: Overrides the Certificate hostname, via
the `certname` setting in `puppet.conf`.  Defaults to
`PUPPETSERVER_HOSTNAME`.
* *PUPPETSERVER_ENVIRONMENT*:  Sets the Puppet environment.  Default
is `production`.
* *PUPPETSERVER_GENCONFIG*:  Generates various configuration files
if and only if they're writable.
* *PUPPETDB_CONFIG*:  If set, will automatically configure PuppetDB.
Several settings automatically set this to `auto`.
* *PUPPETDB_URL*:  The URL of a PuppetDB server.  If unset and
`PUPPETDB_CONFIG` is set, will set itself to the value,
`https://$PUPPETDB_HOST:$PUPPETDB_PORT`.  If set, sets
`PUPPETDB_CONFIG` to `auto`.
* *PUPPETDB_HOST*:  The host for PuppetDB.  Default is `puppetdb`.
If set, sets `PUPPETDB_CONFIG` to `auto`.
* *PUPPETDB_PORT*:  The port for PuppetDB.  Default is `8081`.  If
set, sets `PUPPETDB_CONFIG` to `auto`.

If `PUPPETSERVER_GENCONFIG` is not unset, the container will try to
generate:

* `/etc/puppetlabs/puppet/puppet.conf`
* `/etc/puppetlabs/puppet/puppetdb.conf`
* `/etc/puppetlabs/puppet/routes.yaml`

The container will not attempt to generate these files if they are
read-only, for example if mounted via `docker-compose.yml`:

```
puppetserver:
  image: puppetserver:pc1
  environment:
    PUPPETSERVER_GENCONFIG: yes
    PUPPETSERVER_HOSTNAME: puppet.example.com
  volumes:
    - /opt/containers/puppetserver/conf/puppet.conf:/etc/puppetlabs/puppet/puppet.conf:ro
```

As a practical matter, you can mount an empty configuration file as
writable, start the container, then recreate the container with the
configuration file read-only.  This will generate a default
configuration for tweaking.
