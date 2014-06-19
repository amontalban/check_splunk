check_splunk
============

Simple Nagios plugin to check Splunk services and ports

You need to configure sudo in order this script works i.e:

nagios ALL=(ALL) NOPASSWD: /etc/init.d/splunk status


(Where nagios is the name that nrpe uses to execute commands)
