Various stuff related to ADS-B

collectd.conf
- collectd configuration for PiAware.  This version is configured with collectd's network plugin to create rrd files on a separate host.

make-graphs.sh
- Script to create rrdtool graphs containing dump1090 and other statistics.  This version also has graphs not specific to ADS-B, including:
   - BIND DNS
   - Host uptime
   - Network traffic
   - Wireless signal
   - Disk I/O and space
   - CPU
   - Memory
   - NTP
Some modification will be needed to get this to work in your environment.

piping.sh
- A simple script to monitor PiAware from another host.  It does a simple ping test as well as connecting to the FATSV output port to verify dump1090 is receiving messages.  If these tests fail, and e-mail alert is sent.
