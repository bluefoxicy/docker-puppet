#!/bin/bash

export PUPPETSERVER_HOSTNAME="${PUPPETSERVER_HOSTNAME:-`hostname -f`}"
export PUPPETSERVER_CERTNAME="${PUPPETSERVER_CERTNAME:-$PUPPETSERVER_HOSTNAME}"
export PUPPETSERVER_ENVIRONMENT="${PUPPETSERVER_ENVIRONMENT:-production}"

PUPPET_CONF='/etc/puppetlabs/puppet/puppet.conf'
PUPPETSERVER='puppetserver'
PUPPET='puppet'

# Rewrite puppet.conf if PUPPETSERVER_GENCONFIG is set and
# /etc/puppet.conf is writable.  Mounting this as a read-only
# volume prevents this.
if [ -n "$PUPPETSERVER_GENCONFIG" ] && [ -w "$PUPPET_CONF" ]; then
  sed \
       -e 's#PUPPETSERVER_CERTNAME#'"$PUPPETSERVER_CERTNAME"'#g' \
       -e 's#PUPPETSERVER_ENVIRONMENT#'"$PUPPETSERVER_ENVIRONMENT"'#g' \
       "$PUPPET_CONF".tmpl \
   > "$PUPPET_CONF"
fi

# Create CA Certificates if none
# Must occur after regenerating puppet.conf
if [ ! -e "$($PUPPET master --configprint hostcert)" ]; then
  $PUPPET cert generate "$($PUPPET master --configprint certname)"
fi

exec "$PUPPETSERVER" foreground
