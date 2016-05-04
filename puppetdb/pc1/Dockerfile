FROM ubuntu:14.04

ENV PUPPET_COLLECTION pc1

# Install puppetlabs apt archive
RUN \
     apt update \ 
  && apt install -y wget \
  && wget \
       "https://apt.puppetlabs.com/puppetlabs-release-${PUPPET_COLLECTION}-trusty.deb" \
       -O /tmp/puppetlabs-release.deb \
  && dpkg -i /tmp/puppetlabs-release.deb \
  && rm -f /tmp/puppetlabs-release.deb \
  && apt remove --purge -y wget \
  && apt-get clean \
  && find /var/cache/apt /var/lib/apt/lists -type f -delete

# Install puppetdb,
# set up logging
RUN \
     apt update \ 
  && apt install -y puppetdb \
  && ln -s /opt/puppetlabs/puppet/bin/puppet \
     /usr/local/sbin/ \
  && apt-get clean \
  && find /var/cache/apt /var/lib/apt/lists -type f -delete

copy run-puppetdb.sh /usr/local/sbin/

EXPOSE 8081

CMD ["run-puppetdb.sh"]

