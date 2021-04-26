#!/bin/bash
# Ensure riak.conf exists.
touch /usr/local/riak/etc/riak.conf
# Don't add more configuration to it unless necessary.
if [[ "$RIAK_SKIP_DOCKER_CONF" != 1 ]]; then
  echo >>/usr/local/riak/etc/riak.conf
  while read VAR KEY; do
    if [[ -v "${VAR}" ]] && [[ -n "${!VAR}" ]]; then
      echo "${KEY} = ${!VAR}"
    fi
  done </usr/local/riak/riak.conf.vars >>/usr/local/riak/etc/riak.conf
fi
if [ $# -gt 0 ]; then
  exec bash -c '"$@"' _ "$@"
fi
exec /usr/bin/runsv /var/service/riak
