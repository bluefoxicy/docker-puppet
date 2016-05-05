#!/bin/bash

export PUPPETSERVER_HOSTNAME="${PUPPETSERVER_HOSTNAME:-`hostname -f`}"
export PUPPETSERVER_CERTNAME="${PUPPETSERVER_CERTNAME:-$PUPPETSERVER_HOSTNAME}"
export PUPPETSERVER_ENVIRONMENT="${PUPPETSERVER_ENVIRONMENT:-production}"

# Enable puppetdb config
if [ -n "$PUPPETDB_HOST" ] || [ -n "$PUPPETDB_PORT" ] \
   || [ -n "$PUPPETDB_URL" ]; then
  export PUPPETDB_CONFIG="${PUPPETDB_CONFIG:-auto}"
fi
# PuppetDB URL
if [ -n "$PUPPETDB_CONFIG" ]; then
  export PUPPETDB_HOST="${PUPPETDB_HOST:-puppetdb}"
  export PUPPETDB_PORT="${PUPPETDB_PORT:-8081}"
  export PUPPETDB_URL="${PUPPETDB_URL:-https://${PUPPETDB_HOST}:${PUPPETDB_PORT}}"
fi

PUPPET_CONF='/etc/puppetlabs/puppet/puppet.conf'
PUPPETDB_CONF='/etc/puppetlabs/puppet/puppetdb.conf'
PUPPETSERVER='puppetserver'
PUPPET='puppet'

export PUPPETDB_ROUTEFILE="$($PUPPET master --configprint route_file)"

# Rewrite puppetdb.conf if PUPPETSERVER_GENCONFIG is set and
# /etc/puppet.conf is writable.  Mounting this as a read-only
# volume prevents this.
if [ -n "$PUPPETSERVER_GENCONFIG" ] && \
    ( [ -w "$PUPPET_CONF" ] || [ ! -e "$PUPPET_CONF" ] ); then
  sed \
       -e 's#PUPPETSERVER_CERTNAME#'"$PUPPETSERVER_CERTNAME"'#g' \
       -e 's#PUPPETSERVER_ENVIRONMENT#'"$PUPPETSERVER_ENVIRONMENT"'#g' \
       "$PUPPET_CONF".tmpl \
   > "$PUPPET_CONF"
fi

# Enable PuppetDB configuration iff PUPPETDB_URL is set and other
# conditions apply
if [ -n "$PUPPETSERVER_GENCONFIG" ] && [ -n "$PUPPETDB_URL" ] && \
    ( [ -w "$PUPPETDB_CONF" ] || [ ! -e "$PUPPETDB_CONF" ] ); then
  sed \
       -e 's#PUPPETDB_URL#'"$PUPPETDB_URL"'#g' \
       "$PUPPETDB_CONF".tmpl \
   > "$PUPPETDB_CONF"
  # Also append puppet.conf.puppetdb.tmpl to puppet.conf
  if [ -w "$PUPPET_CONF" ]; then
    cat "$PUPPET_CONF".puppetdb.tmpl >> "$PUPPET_CONF"
  fi

  # and create the routes file
  if [ -w "$PUPPETDB_ROUTEFILE" ] || [ ! -e "$PUPPETDB_ROUTEFILE" ]; then
    cat /etc/puppetlabs/puppet/routes.yaml.tmpl > "$PUPPETDB_ROUTEFILE"
  fi
fi

# Fix permissions
chown -R puppet:puppet "$($PUPPET config print confdir)"

# Create CA Certificates if none
# Must occur after regenerating puppet.conf
if [ ! -e "$($PUPPET master --configprint hostcert)" ]; then
  $PUPPET cert generate "$($PUPPET master --configprint certname)"
fi

exec "$PUPPETSERVER" foreground
