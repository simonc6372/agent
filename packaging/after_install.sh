#!/bin/sh

set -e

[ -f /etc/sysconfig/grafana-agent ] && . /etc/sysconfig/grafana-agent

startAgent() {
  if [ -x /bin/systemctl ] ; then
    /bin/systemctl daemon-reload
		/bin/systemctl start grafana-agent.service
	elif [ -x /etc/init.d/grafana-agent ] ; then
		/etc/init.d/grafana-agent start
	elif [ -x /etc/rc.d/init.d/grafana-agent ] ; then
		/etc/rc.d/init.d/grafana-agent start
	fi
}

stopAgent() {
	if [ -x /bin/systemctl ] ; then
		/bin/systemctl stop grafana-agent.service > /dev/null 2>&1 || :
	elif [ -x /etc/init.d/grafana-agent ] ; then
		/etc/init.d/grafana-agent stop
	elif [ -x /etc/rc.d/init.d/grafana-agent ] ; then
		/etc/rc.d/init.d/grafana-agent stop
	fi
}


# Initial installation: $1 == 1
# Upgrade: $1 == 2, and configured to restart on upgrade
if [ $1 -eq 1 ] ; then
	[ -z "$AGENT_USER" ] && AGENT_USER="grafana-agent"
	[ -z "$AGENT_GROUP" ] && AGENT_GROUP="grafana-agent"
	if ! getent group "$AGENT_GROUP" > /dev/null 2>&1 ; then
    groupadd -r "$AGENT_GROUP"
	fi
	if ! getent passwd "$AGENT_USER" > /dev/null 2>&1 ; then
    useradd -r -g grafana-agent -d /var/lib/grafana-agent  -s /sbin/nologin -c "grafana-agent user" grafana-agent
	fi

	chown $AGENT_USER:$AGENT_GROUP /var/lib/grafana-agent 
	chmod 640 /etc/grafana-agent.yaml
	chown root:$AGENT_GROUP /etc/grafana-agent.yaml 


elif [ $1 -ge 2 ] ; then
  if [ "$RESTART_ON_UPGRADE" == "true" ]; then
    /bin/systemctl reload 
  fi
fi
