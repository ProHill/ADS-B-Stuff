#!/bin/sh
##########################################################################################################
##   State:    Volatile
##  Author:    Andrew Hill, based on original by Xforce30164
## Content: dump-tools make-graph script
## Version:    0.1.0
## Based on dump1090-tools by mutability.
##
## Original License:
## Copyright (c) 2015, Oliver Jowett <oliver@mutability.co.uk>
## 
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
## 
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#########################################################################################################

renice -n 5 -p $$

metric_range_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 max range" \
  --vertical-label "kilometers" \
  --lower-limit 0 \
  --units-exponent 0 \
  "DEF:rangem=$2/dump1090_range-max_range.rrd:value:MAX" \
  "CDEF:range=rangem,0.001,*" \
  "LINE1:range#000000:max range" \
  --watermark "Drawn: $nowlit";
}

imperial_range_graph(){
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 max range" \
  --vertical-label "nautical miles" \
  --lower-limit 0 \
  --units-exponent 0 \
  "DEF:rangem=$2/dump1090_range-max_range.rrd:value:MAX" \
  "CDEF:rangekm=rangem,1000,/" \
  "CDEF:rangenm=rangekm,0.539956803,*" \
  "LINE1:rangenm#0000FF:max range" \
  "VDEF:avgrange=rangenm,AVERAGE" \
  "LINE1:avgrange#666666:avg range\\::dashes" \
  "VDEF:peakrange=rangenm,MAXIMUM" \
  "GPRINT:avgrange:%1.1lf nm" \
  "LINE1:peakrange#FF0000:peak range\\:" \
  "GPRINT:peakrange:%1.1lf nm\c" \
  --watermark "Drawn: $nowlit";
}

signal_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 signal" \
  --vertical-label "dBFS" \
  --upper-limit 0    \
  --lower-limit -50  \
  --rigid            \
  --units-exponent 0 \
  "TEXTALIGN:center" \
  "DEF:signal=$2/dump1090_dbfs-signal.rrd:value:AVERAGE" \
  "DEF:peak=$2/dump1090_dbfs-peak_signal.rrd:value:AVERAGE" \
  "CDEF:us=signal,UN,-100,signal,IF" \
  "AREA:-100#00FF00:mean signal power" \
  "AREA:us#FFFFFF" \
  "LINE1:peak#0000FF:peak signal power" \
  --watermark "Drawn: $nowlit";
}

wireless_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "RPi wlan0 Signal" \
  --rigid            \
  --lower-limit -1 \
  --upper-limit 100 \
  "TEXTALIGN:center" \
  "DEF:power=$2/gauge-wifi_power-wlan0\:.rrd:value:AVERAGE" \
  "DEF:quality=$2/gauge-wifi_quality-wlan0\:.rrd:value:AVERAGE" \
  "DEF:noise=$2/gauge-wifi_noise-wlan0\:.rrd:value:AVERAGE" \
  "LINE1:power#0000FF:signal power" \
  "LINE1:quality#00FF00:signal quality" \
  "LINE1:noise#FF0000:signal noise" \
  --watermark "Drawn: $nowlit";
}


local_rate_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 1010 \
  --height 217 \
  --step "$5" \
  --title "$3 ADS-B message rate" \
  --vertical-label "messages/second" \
  --lower-limit 0  \
  --units-exponent 0 \
  --right-axis 360:0 \
  "TEXTALIGN:center" \
  "DEF:messages=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE" \
  "DEF:strong=$2/dump1090_messages-strong_signals.rrd:value:AVERAGE" \
  "DEF:positions=$2/dump1090_messages-positions.rrd:value:AVERAGE" \
  "CDEF:y2strong=strong,10,*" \
  "CDEF:y2positions=positions,10,*" \
  "LINE1:messages#0000FF:messages received" \
  "AREA:y2strong#FF0000:messages >-3dBFS / hr (RHS)" \
  "LINE1:y2positions#00c0FF:positions / hr (RHS)" \
  --watermark "Drawn: $nowlit";
}

local_rate_graph_24ma() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 1010 \
  --height 217 \
  --step "$5" \
  --title "$3 ADS-B message rate" \
  --vertical-label "messages/second" \
  --lower-limit 0  \
  --units-exponent 0 \
  --right-axis 360:0 \
  --slope-mode \
  "TEXTALIGN:center" \
  "DEF:messages=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE" \
  "DEF:messagestoday=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE:start=12am today" \
  "DEF:a=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE:end=now-86400:start=end-86400" \
  "DEF:b=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE:end=now-172800:start=end-86400" \
  "DEF:c=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE:end=now-259200:start=end-86400" \
  "DEF:d=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE:end=now-345600:start=end-86400" \
  "DEF:e=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE:end=now-432000:start=end-86400" \
  "DEF:f=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE:end=now-518400:start=end-86400" \
  "DEF:g=$2/dump1090_messages-local_accepted.rrd:value:AVERAGE:end=now-604800:start=end-86400" \
  "DEF:amin=$2/dump1090_messages-local_accepted.rrd:value:MIN:end=now-86400:start=end-86400" \
  "DEF:bmin=$2/dump1090_messages-local_accepted.rrd:value:MIN:end=now-172800:start=end-86400" \
  "DEF:cmin=$2/dump1090_messages-local_accepted.rrd:value:MIN:end=now-259200:start=end-86400" \
  "DEF:dmin=$2/dump1090_messages-local_accepted.rrd:value:MIN:end=now-345600:start=end-86400" \
  "DEF:emin=$2/dump1090_messages-local_accepted.rrd:value:MIN:end=now-432000:start=end-86400" \
  "DEF:fmin=$2/dump1090_messages-local_accepted.rrd:value:MIN:end=now-518400:start=end-86400" \
  "DEF:gmin=$2/dump1090_messages-local_accepted.rrd:value:MIN:end=now-604800:start=end-86400" \
  "DEF:amax=$2/dump1090_messages-local_accepted.rrd:value:MAX:end=now-86400:start=end-86400" \
  "DEF:bmax=$2/dump1090_messages-local_accepted.rrd:value:MAX:end=now-172800:start=end-86400" \
  "DEF:cmax=$2/dump1090_messages-local_accepted.rrd:value:MAX:end=now-259200:start=end-86400" \
  "DEF:dmax=$2/dump1090_messages-local_accepted.rrd:value:MAX:end=now-345600:start=end-86400" \
  "DEF:emax=$2/dump1090_messages-local_accepted.rrd:value:MAX:end=now-432000:start=end-86400" \
  "DEF:fmax=$2/dump1090_messages-local_accepted.rrd:value:MAX:end=now-518400:start=end-86400" \
  "DEF:gmax=$2/dump1090_messages-local_accepted.rrd:value:MAX:end=now-604800:start=end-86400" \
  "DEF:strong=$2/dump1090_messages-strong_signals.rrd:value:AVERAGE" \
  "DEF:positions=$2/dump1090_messages-positions.rrd:value:AVERAGE" \
  "DEF:positionstoday=$2/dump1090_messages-positions.rrd:value:AVERAGE:start=12am today" \
  "CDEF:y2strong=strong,10,*" \
  "CDEF:y2positions=positions,10,*" \
  "SHIFT:a:86400" \
  "SHIFT:b:172800" \
  "SHIFT:c:259200" \
  "SHIFT:d:345600" \
  "SHIFT:e:432000" \
  "SHIFT:f:518400" \
  "SHIFT:g:604800" \
  "SHIFT:amin:86400" \
  "SHIFT:bmin:172800" \
  "SHIFT:cmin:259200" \
  "SHIFT:dmin:345600" \
  "SHIFT:emin:432000" \
  "SHIFT:fmin:518400" \
  "SHIFT:gmin:604800" \
  "SHIFT:amax:86400" \
  "SHIFT:bmax:172800" \
  "SHIFT:cmax:259200" \
  "SHIFT:dmax:345600" \
  "SHIFT:emax:432000" \
  "SHIFT:fmax:518400" \
  "SHIFT:gmax:604800" \
  "VDEF:positionstodaytotal=positions,TOTAL" \
  "CDEF:7dayaverage=a,b,c,d,e,f,g,ADDNAN,ADDNAN,ADDNAN,ADDNAN,ADDNAN,ADDNAN,7,/" \
  "CDEF:min1=amin,bmin,MINNAN" \
  "CDEF:min2=cmin,dmin,MINNAN" \
  "CDEF:min3=emin,fmin,MINNAN" \
  "CDEF:min4=min1,min2,MINNAN" \
  "CDEF:min5=min3,gmin,MINNAN" \
  "CDEF:min=min4,min5,MINNAN" \
  "CDEF:max1=amax,bmax,MAXNAN" \
  "CDEF:max2=cmax,dmax,MAXNAN" \
  "CDEF:max3=emax,fmax,MAXNAN" \
  "CDEF:max4=max1,max2,MAXNAN" \
  "CDEF:max5=max3,gmax,MAXNAN" \
  "CDEF:max=max4,max5,MAXNAN" \
  "CDEF:maxarea=max,min,-" \
  "LINE1:min#FFFF99:mins" \
  "AREA:maxarea#FFFF99:max:STACK" \
  "LINE1:7dayaverage#00FF00:7 day average" \
  "AREA:y2strong#FF0000:messages >-3dBFS / hr (RHS)" \
  "LINE1:y2positions#00c0FF:positions / hr (RHS)" \
  "LINE1:messages#0000FF:messages received" \
  --watermark "Drawn: $nowlit";

}

remote_rate_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 message rate" \
  --vertical-label "messages/second" \
  --lower-limit 0  \
  --units-exponent 0 \
  --right-axis 360:0 \
  "TEXTALIGN:center" \
  "DEF:messages=$2/dump1090_messages-remote_accepted.rrd:value:AVERAGE" \
  "DEF:positions=$2/dump1090_messages-positions.rrd:value:AVERAGE" \
  "CDEF:y2positions=positions,10,*" \
  "LINE1:messages#0000FF:messages received" \
  "LINE1:y2positions#00c0FF:position / hr (RHS)" \
  --watermark "Drawn: $nowlit";
}

aircraft_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 aircraft seen" \
  --vertical-label "aircraft" \
  --lower-limit 0 \
  --units-exponent 0 \
  "TEXTALIGN:center" \
  "DEF:all=$2/dump1090_aircraft-recent.rrd:total:AVERAGE" \
  "DEF:pos=$2/dump1090_aircraft-recent.rrd:positions:AVERAGE" \
  "DEF:mlat=$2/dump1090_mlat-recent.rrd:value:AVERAGE" \
  "VDEF:avgac=all,AVERAGE" \
  "VDEF:maxac=all,MAXIMUM" \
  "AREA:all#4169E160:aircraft tracked" \
  "GPRINT:avgac:avg\: %3.0lf" \
  "GPRINT:maxac:max\: %3.0lf" \
  "LINE1:pos#4169E1:aircraft with positions" \
  "LINE1:mlat#00FF00:mlat" \
  --watermark "Drawn: $nowlit";
}

tracks_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 tracks seen" \
  --vertical-label "tracks/hour" \
  --lower-limit 0 \
  --units-exponent 0 \
  "TEXTALIGN:center" \
  "DEF:all=$2/dump1090_tracks-all.rrd:value:AVERAGE" \
  "DEF:single=$2/dump1090_tracks-single_message.rrd:value:AVERAGE" \
  "CDEF:hall=all,3600,*" \
  "CDEF:hsingle=single,3600,*" \
  "AREA:hsingle#FF0000:tracks with single message" \
  "AREA:hall#00FF00:unique tracks:STACK" \
  --watermark "Drawn: $nowlit";
}

adsb_cpu_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 ADS-B Process Utilization" \
  --vertical-label "CPU %" \
  --lower-limit 0 \
  --upper-limit 100 \
  --rigid \
  "TEXTALIGN:center" \
  "DEF:demod=$2/dump1090_cpu-demod.rrd:value:AVERAGE" \
  "CDEF:demodp=demod,10,/" \
  "DEF:reader=$2/dump1090_cpu-reader.rrd:value:AVERAGE" \
  "CDEF:readerp=reader,10,/" \
  "DEF:background=$2/dump1090_cpu-background.rrd:value:AVERAGE" \
  "CDEF:backgroundp=background,10,/" \
  "AREA:readerp#008000:USB" \
  "AREA:backgroundp#00C000:other:STACK" \
  "AREA:demodp#00FF00:demodulator:STACK" \
  --watermark "Drawn: $nowlit";
}

cpu_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 428 \
  --height 172 \
  --step "$5" \
  --title "$3 CPU Utilization & Temp" \
  --vertical-label "CPU Usage (%)" \
  --lower-limit 0 \
  --upper-limit 100 \
  --right-axis 1.5:0 \
  --right-axis-label "Temperature (℉)" \
  --rigid \
  "DEF:user=$2/cpu-user.rrd:value:AVERAGE" \
  "DEF:nice=$2/cpu-nice.rrd:value:AVERAGE" \
  "DEF:system=$2/cpu-system.rrd:value:AVERAGE" \
  "DEF:idle=$2/cpu-idle.rrd:value:AVERAGE" \
  "CDEF:total=user,nice,+,system,+,idle,+" \
  "CDEF:userperc=user,total,/,100,*" \
  "CDEF:niceperc=nice,total,/,100,*" \
  "CDEF:systemperc=system,total,/,100,*" \
  "CDEF:idleperc=idle,total,/,100,*" \
  "CDEF:totusedperc=userperc,niceperc,+,systemperc,+" \
  "DEF:traw=$2/../table-rpi/gauge-cpu_temp.rrd:value:MAX" \
  "CDEF:tta=traw,1000,/" \
  "CDEF:ttb=tta,1.8,*" \
  "CDEF:ttc=ttb,32,+" \
  "CDEF:ttcscaled=ttc,1.5,/" \
  "TEXTALIGN:left" \
  "AREA:systemperc#4169E1:System" \
  "GPRINT:systemperc:AVERAGE:Average\:%4.0lf%%" \
  "GPRINT:systemperc:MAX:Maximum\:%4.0lf%%" \
  "STACK:userperc#32C734:User" \
  "GPRINT:userperc:AVERAGE:Average\:%4.0lf%%" \
  "GPRINT:userperc:MAX:Maximum\:%4.0lf%%\n" \
  "STACK:niceperc#00FF00:Nice" \
  "GPRINT:niceperc:AVERAGE:  Average\:%4.0lf%%" \
  "GPRINT:niceperc:MAX:Maximum\:%4.0lf%%" \
  "STACK:idleperc#FFFFFF:Idle" \
  "GPRINT:idleperc:AVERAGE:Average\:%4.0lf%%" \
  "GPRINT:idleperc:MAX:Maximum\:%4.0lf%%\n" \
  "LINE1:ttcscaled#FFCC00:Temp" \
  "GPRINT:ttc:AVERAGE:  Average\: %3.0lfF"  \
  "GPRINT:ttc:MAX:Maximum\: %3.0lfF" \
  --watermark "Drawn: $nowlit";
}

cpu_only_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 CPU Utilization" \
  --vertical-label "CPU Usage (%)" \
  --lower-limit 0 \
  --upper-limit 100 \
  --rigid \
  "DEF:user=$2/cpu-user.rrd:value:AVERAGE" \
  "DEF:nice=$2/cpu-nice.rrd:value:AVERAGE" \
  "DEF:system=$2/cpu-system.rrd:value:AVERAGE" \
  "DEF:idle=$2/cpu-idle.rrd:value:AVERAGE" \
  "CDEF:total=user,nice,+,system,+,idle,+" \
  "CDEF:userperc=user,total,/,100,*" \
  "CDEF:niceperc=nice,total,/,100,*" \
  "CDEF:systemperc=system,total,/,100,*" \
  "CDEF:idleperc=idle,total,/,100,*" \
  "CDEF:totusedperc=userperc,niceperc,+,systemperc,+" \
  "TEXTALIGN:left" \
  "AREA:systemperc#4169E1:System" \
  "GPRINT:systemperc:AVERAGE:Average\:%4.0lf%%" \
  "GPRINT:systemperc:MAX:Maximum\:%4.0lf%%" \
  "STACK:userperc#32C734:User" \
  "GPRINT:userperc:AVERAGE:Average\:%4.0lf%%" \
  "GPRINT:userperc:MAX:Maximum\:%4.0lf%%\n" \
  "STACK:niceperc#00FF00:Nice" \
  "GPRINT:niceperc:AVERAGE:  Average\:%4.0lf%%" \
  "GPRINT:niceperc:MAX:Maximum\:%4.0lf%%" \
  "STACK:idleperc#FFFFFF:Idle" \
  "GPRINT:idleperc:AVERAGE:Average\:%4.0lf%%" \
  "GPRINT:idleperc:MAX:Maximum\:%4.0lf%%\n" \
  --watermark "Drawn: $nowlit";
}

memory_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 Memory" \
  --vertical-label "" \
  "TEXTALIGN:center" \
  "DEF:buffered=$2/memory-buffered.rrd:value:AVERAGE" \
  "DEF:cached=$2/memory-cached.rrd:value:AVERAGE" \
  "DEF:free=$2/memory-free.rrd:value:AVERAGE" \
  "DEF:used=$2/memory-used.rrd:value:AVERAGE" \
  "AREA:used#4169E1:used" \
  "STACK:buffered#32C734:buffered" \
  "STACK:cached#00FF00:cached" \
  "STACK:free#FFFFFF:free" \
  --watermark "Drawn: $nowlit";
}

df_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 Disk Space (/)" \
  --vertical-label "" \
  --lower-limit 0  \
  "TEXTALIGN:center" \
  "DEF:used=$2/df_complex-used.rrd:value:AVERAGE" \
  "DEF:reserved=$2/df_complex-reserved.rrd:value:AVERAGE" \
  "DEF:free=$2/df_complex-free.rrd:value:AVERAGE" \
  "CDEF:totalused=used,reserved,+" \
  "AREA:totalused#4169E1:used:STACK" \
  "AREA:free#32C734:free:STACK" \
  --watermark "Drawn: $nowlit";
}

net_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 Bandwidth - eth0" \
  --vertical-label "bytes/sec" \
  "TEXTALIGN:center" \
  "DEF:rx=$2/if_octets.rrd:rx:AVERAGE" \
  "DEF:tx=$2/if_octets.rrd:tx:AVERAGE" \
  "CDEF:tx_neg=tx,-1,*" \
  "AREA:rx#32CD32:Incoming" \
  "LINE1:rx#336600" \
  "GPRINT:rx:MAX:Max\: %5.1lf %sB/sec" \
  "GPRINT:rx:AVERAGE:Avg\: %5.1lf %SB/sec" \
  "GPRINT:rx:LAST:Current\: %5.1lf %SB/sec\c" \
  "AREA:tx_neg#4169E1:Outgoing" \
  "LINE1:tx_neg#0033CC" \
  "GPRINT:tx:MAX:Max\: %5.1lf %sB/sec" \
  "GPRINT:tx:AVERAGE:Avg\: %5.1lf %SB/sec" \
  "GPRINT:tx:LAST:Current\: %5.1lf %SB/sec\c" \
  "HRULE:0#000000" \
  --watermark "Drawn: $nowlit";
}

diskio_merged_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "Merged Disk Ops" \
  --vertical-label "IOPS" \
  "TEXTALIGN:center" \
  "DEF:read=$2/disk_merged.rrd:read:AVERAGE" \
  "DEF:write=$2/disk_merged.rrd:write:AVERAGE" \
  "CDEF:write_neg=write,-1,*" \
  "AREA:read#32CD32:Reads \c" \
  "LINE1:read#336600" \
  "GPRINT:read:MAX:Max\:%8.1lf" \
  "GPRINT:read:AVERAGE:Avg\:%8.1lf" \
  "GPRINT:read:LAST:Current\:%8.1lf iops\n" \
  "AREA:write_neg#4169E1:Writes" \
  "LINE1:write_neg#0033CC" \
  "GPRINT:write:MAX:Max\:%8.1lf" \
  "GPRINT:write:AVERAGE:Avg\:%8.1lf" \
  "GPRINT:write:LAST:Current\:%8.1lf iops\c" \
  "HRULE:0#000000" \
  --watermark "Drawn: $nowlit";
}

diskio_ops_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 Disk I/O - IOPS" \
  --vertical-label "IOPS" \
  "TEXTALIGN:center" \
  "DEF:read=$2/disk_ops.rrd:read:AVERAGE" \
  "DEF:write=$2/disk_ops.rrd:write:AVERAGE" \
  "CDEF:write_neg=write,-1,*" \
  "AREA:read#32CD32:Reads " \
  "LINE1:read#336600" \
  "GPRINT:read:MAX:Max\:%5.1lf iops" \
  "GPRINT:read:AVERAGE:Avg\:%5.1lf iops" \
  "GPRINT:read:LAST:Current\:%5.1lf iops\c" \
  "TEXTALIGN:center" \
  "AREA:write_neg#4169E1:Writes" \
  "LINE1:write_neg#0033CC" \
  "GPRINT:write:MAX:Max\:%5.1lf iops" \
  "GPRINT:write:AVERAGE:Avg\:%5.1lf iops" \
  "GPRINT:write:LAST:Current\:%5.1lf iops\c" \
  "HRULE:0#000000" \
  --watermark "Drawn: $nowlit";
}

diskio_octets_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 Disk I/O - Bandwidth" \
  --vertical-label "Bytes/s" \
  "TEXTALIGN:center" \
  "DEF:read=$2/disk_octets.rrd:read:AVERAGE" \
  "DEF:write=$2/disk_octets.rrd:write:AVERAGE" \
  "CDEF:write_neg=write,-1,*" \
  "AREA:read#32CD32:Reads " \
  "LINE1:read#336600" \
  "GPRINT:read:MAX:Max\: %5.1lf %sB/sec" \
  "GPRINT:read:AVERAGE:Avg\: %5.1lf %SB/sec" \
  "GPRINT:read:LAST:Current\: %5.1lf %SB/sec\c" \
  "TEXTALIGN:center" \
  "AREA:write_neg#4169E1:Writes" \
  "LINE1:write_neg#0033CC" \
  "GPRINT:write:MAX:Max\: %5.1lf %sB/sec" \
  "GPRINT:write:AVERAGE:Avg\: %5.1lf %SB/sec" \
  "GPRINT:write:LAST:Current\: %5.1lf %SB/sec\c" \
  "HRULE:0#000000" \
  --watermark "Drawn: $nowlit";
}

ntp_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "NTP Statistics" \
  --vertical-label "seconds" \
  "TEXTALIGN:center" \
  "DEF:time-offset-error=$2/time_offset-error.rrd:value:AVERAGE" \
  "DEF:time-offset-loop=$2/time_offset-loop.rrd:value:AVERAGE" \
  "DEF:freq-offset-loop=$2/frequency_offset-loop.rrd:value:AVERAGE" \
  "LINE1:time-offset-error#336600:Time Offset Error" \
  "GPRINT:time-offset-error:MAX:Max\: %5.1lf %ssec" \
  "GPRINT:time-offset-error:AVERAGE:Avg\: %5.1lf %Ssec" \
  "GPRINT:time-offset-error:LAST:Current\: %5.1lf %Ssec\c" \
  "LINE1:time-offset-loop#0033CC:Time Offset Loop" \
  "GPRINT:time-offset-loop:MAX:Max\: %5.1lf %ssec" \
  "GPRINT:time-offset-loop:AVERAGE:Avg\: %5.1lf %Ssec" \
  "GPRINT:time-offset-loop:LAST:Current\: %5.1lf %Ssec\c" \
  --watermark "Drawn: $nowlit";
}

net_fa_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "FlightAware Bandwidth Usage" \
  --vertical-label "bytes/sec" \
  "TEXTALIGN:center" \
  "DEF:rx7042tcp=$2/iptables-filter-INPUT/ipt_bytes-fa-70-42-tcp.rrd:value:AVERAGE" \
  "DEF:rx7042udp=$2/iptables-filter-INPUT/ipt_bytes-fa-70-42-udp.rrd:value:AVERAGE" \
  "DEF:rx89151=$2/iptables-filter-INPUT/ipt_bytes-fa-89-151.rrd:value:AVERAGE" \
  "DEF:rx206123=$2/iptables-filter-INPUT/ipt_bytes-fa-206-123.rrd:value:AVERAGE" \
  "DEF:rx207210=$2/iptables-filter-INPUT/ipt_bytes-fa-207-210.rrd:value:AVERAGE" \
  "DEF:rx21652=$2/iptables-filter-INPUT/ipt_bytes-fa-216-52.rrd:value:AVERAGE" \
  "CDEF:rx=rx7042tcp,rx7042udp,rx89151,rx206123,rx207210,rx21652,+,+,+,+,+" \
  "DEF:tx7042tcp=$2/iptables-filter-OUTPUT/ipt_bytes-fa-70-42-tcp.rrd:value:AVERAGE" \
  "DEF:tx7042udp=$2/iptables-filter-OUTPUT/ipt_bytes-fa-70-42-udp.rrd:value:AVERAGE" \
  "DEF:tx89151=$2/iptables-filter-OUTPUT/ipt_bytes-fa-89-151.rrd:value:AVERAGE" \
  "DEF:tx206123=$2/iptables-filter-OUTPUT/ipt_bytes-fa-206-123.rrd:value:AVERAGE" \
  "DEF:tx207210=$2/iptables-filter-OUTPUT/ipt_bytes-fa-207-210.rrd:value:AVERAGE" \
  "DEF:tx21652=$2/iptables-filter-OUTPUT/ipt_bytes-fa-216-52.rrd:value:AVERAGE" \
  "CDEF:tx=tx7042tcp,tx7042udp,tx89151,tx206123,tx207210,tx21652,+,+,+,+,+" \
  "CDEF:tx_neg=tx,-1,*" \
  "CDEF:tx_tcp_neg=tx7042tcp,-1,*" \
  "CDEF:tx_udp_neg=tx7042udp,-1,*" \
  "CDEF:tx_total=tx_tcp_neg,tx_udp_neg,+" \
  "AREA:rx7042tcp#32CD32:rx ads-b" \
  "LINE1:rx7042tcp#336600" \
  "LINE1:rx7042udp#0033CC" \
  "GPRINT:rx7042tcp:MAX:Max\: %6.1lf %sB/sec" \
  "GPRINT:rx7042tcp:AVERAGE:Avg\: %6.1lf %SB/sec" \
  "GPRINT:rx7042tcp:LAST:Current\: %6.1lf %SB/sec\c" \
  "AREA:rx7042udp#32CD3280:rx  mlat" \
  "GPRINT:rx7042udp:MAX:Max\: %6.1lf %sB/sec" \
  "GPRINT:rx7042udp:AVERAGE:Avg\: %6.1lf %SB/sec" \
  "GPRINT:rx7042udp:LAST:Current\: %6.1lf %SB/sec\c" \
  "AREA:tx_tcp_neg#4169E1:tx ads-b" \
  "GPRINT:tx7042tcp:MAX:Max\: %6.1lf %sB/sec" \
  "GPRINT:tx7042tcp:AVERAGE:Avg\: %6.1lf %SB/sec" \
  "GPRINT:tx7042tcp:LAST:Current\: %6.1lf %SB/sec\c" \
  "AREA:tx_udp_neg#4169E180:tx  mlat" \
  "GPRINT:tx7042udp:MAX:Max\: %6.1lf %sB/sec" \
  "GPRINT:tx7042udp:AVERAGE:Avg\: %6.1lf %SB/sec" \
  "GPRINT:tx7042udp:LAST:Current\: %6.1lf %SB/sec\c" \
  "LINE1:tx_tcp_neg#0033CC" \
  "LINE1:tx_udp_neg#0033CC" \
  "HRULE:0#000000" \
   --watermark "Drawn: $nowlit";
}

metric_temp_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "Core Temperature" \
  --vertical-label "Degrees Celcius" \
  --lower-limit 0 \
  --upper-limit 100 \
  --rigid \
  --units-exponent 1 \
  "DEF:traw=$2/gauge-cpu_temp.rrd:value:MAX" \
  "CDEF:tfin=traw,1000,/" \
  "AREA:tfin#ffcc00" \
  --watermark "Drawn: $nowlit";
}

imperial_temp_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "Core Temperature" \
  --vertical-label "Degrees Fahrenheit" \
  --lower-limit 32 \
  --upper-limit 212 \
  --rigid \
  --units-exponent 1 \
  "DEF:traw=$2/gauge-cpu_temp.rrd:value:MAX" \
  "CDEF:tta=traw,1000,/" \
  "CDEF:ttb=tta,32,+" \
  "CDEF:ttc=ttb,1.8,*" \
  "AREA:ttc#ffcc00" \
  --watermark "Drawn: $nowlit";
}

predict_graph() {
  rrdtool graph \
  "$1" \
  --start=-3days \
  --end=+3days \
  --width=1600 \
  --height=850 \
  --alt-autoscale-max \
  --slope-mode \
  --title="Message rate forecast" \
  "TEXTALIGN:center" \
  "DEF:value=/var/lib/collectd/rrd/piaware/dump1090-rpi/dump1090_messages-local_accepted.rrd:value:AVERAGE:start=-14days" \
  "LINE1:value#ff0000:actual" \
  "CDEF:predict=86400,-7,1600,value,PREDICT" \
  "CDEF:sigma=86400,-7,1600,value,PREDICTSIGMA" \
  "CDEF:upper=predict,sigma,2,*,+" \
  "CDEF:lower=predict,sigma,2,*,-" \
  "LINE1:predict#00ff00:predicted" \
  "LINE1:upper#0000ff:upper certainty limit" \
  "LINE1:lower#0000ff:lower certainty limit" \
  "CDEF:exceeds=value,UN,0,value,lower,upper,LIMIT,UN,IF" \
  "TICK:exceeds#F6D8CE80:1" \
  --watermark "Drawn: $nowlit";
}

#
# Hillsrv1 Graphs
#

bind_hillhome_qtypes_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "Bind Queries - hillhome.org" \
  --vertical-label "Events" \
  "TEXTALIGN:center" \
  "DEF:a=$2/dns_qtype-A.rrd:value:AVERAGE" \
  "DEF:aaaa=$2/dns_qtype-AAAA.rrd:value:AVERAGE" \
  "DEF:ns=$2/dns_qtype-NS.rrd:value:AVERAGE" \
  "DEF:ptr=$2/dns_qtype-PTR.rrd:value:AVERAGE" \
  "DEF:soa=$2/dns_qtype-SOA.rrd:value:AVERAGE" \
  "DEF:srv=$2/dns_qtype-SRV.rrd:value:AVERAGE" \
  "DEF:mx=$2/dns_qtype-MX.rrd:value:AVERAGE" \
  "LINE1:a#7C6CD7:A" \
  "LINE1:aaaa#894F5A:AAAA" \
  "LINE1:ns#85A99B:NS" \
  "LINE1:ptr#38CED2:PTR" \
  "LINE1:soa#424C91:SOA" \
  "LINE1:srv#EE8274:SRV" \
  "LINE1:mx#3CF597:MX" \
   --watermark "Drawn: $nowlit";
}

bind_global_qtypes_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "Bind Queries - global" \
  --vertical-label "Events" \
  "TEXTALIGN:center" \
  "DEF:a=$2/dns_qtype-A.rrd:value:AVERAGE" \
  "DEF:aaaa=$2/dns_qtype-AAAA.rrd:value:AVERAGE" \
  "DEF:ixfr=$2/dns_qtype-IXFR.rrd:value:AVERAGE" \
  "DEF:ptr=$2/dns_qtype-PTR.rrd:value:AVERAGE" \
  "DEF:soa=$2/dns_qtype-SOA.rrd:value:AVERAGE" \
  "DEF:srv=$2/dns_qtype-SRV.rrd:value:AVERAGE" \
  "DEF:mx=$2/dns_qtype-MX.rrd:value:AVERAGE" \
  "LINE1:a#7C6CD7:A" \
  "LINE1:aaaa#894F5A:AAAA" \
  "LINE1:ixfr#85A99B:IXFR" \
  "LINE1:ptr#38CED2:PTR" \
  "LINE1:soa#424C91:SOA" \
  "LINE1:srv#EE8274:SRV" \
  "LINE1:mx#3CF597:MX" \
   --watermark "Drawn: $nowlit";
}

bind_global_queryresp_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "Bind Query Response - global" \
  --vertical-label "Events" \
  "TEXTALIGN:center" \
  "DEF:auth=$2/dns_query-authorative.rrd:value:AVERAGE" \
  "DEF:drop=$2/dns_query-dropped.rrd:value:AVERAGE" \
  "DEF:dup=$2/dns_query-dupliate.rrd:value:AVERAGE" \
  "DEF:fail=$2/dns_query-failure.rrd:value:AVERAGE" \
  "DEF:nonauth=$2/dns_query-nonauth.rrd:value:AVERAGE" \
  "DEF:recurs=$2/dns_query-recursion.rrd:value:AVERAGE" \
  "DEF:refer=$2/dns_query-referral.rrd:value:AVERAGE" \
  "LINE1:auth#7C6CD7:Authoritative" \
  "LINE1:drop#894F5A:Dropped" \
  "LINE1:dup#85A99B:Dupliate" \
  "LINE1:fail#38CED2:Failure" \
  "LINE1:nonauth#424C91:Non-Authoritative" \
  "LINE1:recurs#EE8274:Recursion" \
  "LINE1:refer#3CF597:Referral" \
   --watermark "Drawn: $nowlit";
}

bind_global_serverrespcode_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "Bind Response Codes - global" \
  --vertical-label "Events" \
  "TEXTALIGN:center" \
  "DEF:txformerr=$2/dns_rcode-tx-FORMERR.rrd:value:AVERAGE" \
  "DEF:txnoerror=$2/dns_rcode-tx-NOERROR.rrd:value:AVERAGE" \
  "DEF:txnxdomain=$2/dns_rcode-tx-NXDOMAIN.rrd:value:AVERAGE" \
  "DEF:txnxrrset=$2/dns_rcode-tx-NXRRSET.rrd:value:AVERAGE" \
  "DEF:txservfail=$2/dns_rcode-tx-SERVFAIL.rrd:value:AVERAGE" \
  "LINE1:txformerr#7C6CD7:tx-FORMERR" \
  "LINE1:txnoerror#894F5A:tx-NOERROR" \
  "LINE1:txnxdomain#85A99B:tx-NXDOMAIN" \
  "LINE1:txnxrrset#38CED2:tx-NXRRSET" \
  "LINE1:txservfail#424C91:tx-SERVFAIL" \
   --watermark "Drawn: $nowlit";
}

uptime_graph() {
  firsttimestamp=`rrdtool first $2/uptime.rrd`
  lasttimestamp=`rrdtool last $2/uptime.rrd`
  firsttime=`date -d @$firsttimestamp '+%m/%d/%y %H\:%M %Z'`
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 Uptime" \
  --vertical-label "Days" \
  "TEXTALIGN:center" \
  "DEF:uptimesecs=$2/uptime.rrd:value:AVERAGE" \
  "CDEF:uptimedays=uptimesecs,86400,/" \
  "CDEF:days=uptimesecs,DUP,86400,%,-,86400,/" \
  "CDEF:hours=uptimesecs,86400,%,DUP,3600,%,-,3600,/" \
  "CDEF:minutes=uptimesecs,3600,%,DUP,60,%,-,60,/" \
  "DEF:uptimemax=$2/uptime.rrd:value:MAX" \
  "DEF:uptimemin=$2/uptime.rrd:value:MIN" \
  "DEF:uptimeavg=$2/uptime.rrd:value:AVERAGE" \
  "CDEF:uptimeavgdays=uptimeavg,86400,/" \
  "VDEF:uptimeavgdaysavg=uptimeavgdays,AVERAGE" \
  "VDEF:uptimeavgdaysmax=uptimeavgdays,MAXIMUM" \
  "CDEF:uptimepercent=uptimeavg,$lasttimestamp,$firsttimestamp,-,/,100,*" \
  "CDEF:uptimepercent100=uptimepercent,100,GT,100,uptimepercent,IF" \
  "AREA:uptimedays#4169E180" \
  "LINE2:uptimedays#4169E1:Current" \
  "GPRINT:days:LAST:%2.0lf days" \
  "GPRINT:hours:LAST:%2.0lf hours" \
  "GPRINT:minutes:LAST:%2.0lf minutes\c" \
  "LINE1:uptimeavgdaysavg#666666:Average:dashes" \
  "LINE1:uptimeavgdaysmax#FF0000:Maximum" \
   --watermark "Drawn: $nowlit";
}

disabled_from_above() {
  "LINE1:uptimeavgdaysavg#666666:Average:dashes" \
  "GPRINT:avgdays:LAST:%2.0lf days" \
  "GPRINT:avghours:LAST:%2.0lf hours" \
  "GPRINT:avgminutes:LAST:%2.0lf minutes\c" \
  "LINE1:uptimeavgdaysmax#FF0000:Maximum" \
  "GPRINT:maxdays:LAST:%2.0lf days" \
  "GPRINT:maxhours:LAST:%2.0lf hours" \
  "GPRINT:maxminutes:LAST:%2.0lf minutes\c" \
  "GPRINT:uptimepercent100:LAST:%2.3lf %% uptime since $firsttime"
}

ping_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 Ping Latency" \
  --vertical-label "ms" \
  "TEXTALIGN:center" \
  "DEF:gatewaylatency=$2/ping-107.201.56.1.rrd:value:AVERAGE" \
  "DEF:googlednslatency=$2/ping-8.8.8.8.rrd:value:AVERAGE" \
  "DEF:googlednsdrops=$2/ping_droprate-8.8.8.8.rrd:value:AVERAGE" \
  "DEF:gatewaydrops=$2/ping_droprate-107.201.56.1.rrd:value:AVERAGE" \
  "LINE1:gatewaylatency#4169E1:U-Verse GW" \
  "GPRINT:gatewaylatency:MAX:Max\: %2.1lf ms" \
  "GPRINT:gatewaylatency:AVERAGE:Avg\: %2.1lf ms" \
  "GPRINT:gatewaylatency:LAST:Current\: %2.1lf ms" \
  "AREA:gatewaydrops#4169E180:Drops" \
  "GPRINT:gatewaydrops:AVERAGE: %2.0lf\c" \
  "LINE1:googlednslatency#32CD32:Google DNS" \
  "GPRINT:googlednslatency:MAX:Max\: %2.1lf ms" \
  "GPRINT:googlednslatency:AVERAGE:Avg\: %2.1lf ms" \
  "GPRINT:googlednslatency:LAST:Current\: %2.1lf ms" \
  "AREA:googlednsdrops#32CD3280:Drops" \
  "GPRINT:googlednsdrops:AVERAGE: %2.0lf\c" \
  "HRULE:0#000000" \
   --watermark "Drawn: $nowlit";
}

openvpn_graph() {
  rrdtool graph \
  "$1" \
  --start end-$4 \
  --width 480 \
  --height 200 \
  --step "$5" \
  --title "$3 OpenVPN Sessions" \
  --upper-limit 5 \
  --lower-limit 0 \
  --vertical-label "Users" \
  "TEXTALIGN:center" \
  "DEF:usercount=$2/users-openvpn-status.log.rrd:value:AVERAGE" \
  "DEF:hourlyaverage=$2/users-openvpn-status.log.rrd:value:AVERAGE:step=3600" \
  "AREA:usercount#4169E1:Users" \
  "GPRINT:usercount:MAX:Max\: %2.0lf" \
  "GPRINT:usercount:AVERAGE:Avg\: %2.0lf" \
  "GPRINT:usercount:LAST:Current\: %2.0lf" \
  "LINE1:hourlyaverage#32CD32:1h Average" \
   --watermark "Drawn: $nowlit";
}

common_graphs() {
  aircraft_graph /srv/www/htdocs/piaware/dump1090-$2-acs-$4.png /var/lib/collectd/rrd/$1/dump1090-$2 "$3" "$4" "$5"
  adsb_cpu_graph /srv/www/htdocs/piaware/dump1090-$2-cpu-$4.png /var/lib/collectd/rrd/$1/dump1090-$2 "$3" "$4" "$5"
  cpu_graph /srv/www/htdocs/piaware/$2-cpu-$4.png /var/lib/collectd/rrd/$1/aggregation-cpu-average "$3" "$4" "$5"
  memory_graph /srv/www/htdocs/piaware/dump1090-$2-memory-$4.png /var/lib/collectd/rrd/$1/memory "$3" "$4" "$5"
  df_graph /srv/www/htdocs/piaware/$2-df-root-$4.png /var/lib/collectd/rrd/$1/df-root "$3" "$4" "$5"
  net_graph /srv/www/htdocs/piaware/$2-eth0-$4.png /var/lib/collectd/rrd/$1/interface-eth0 "$3" "$4" "$5"
  #diskio_merged_graph /srv/www/htdocs/piaware/$2-disk-merged-$4.png /var/lib/collectd/rrd/$1/disk-mmcblk0 "$3" "$4" "$5"
  diskio_ops_graph /srv/www/htdocs/piaware/$2-disk-ops-$4.png /var/lib/collectd/rrd/$1/disk-mmcblk0 "$3" "$4" "$5"
  diskio_octets_graph /srv/www/htdocs/piaware/$2-disk-octets-$4.png /var/lib/collectd/rrd/$1/disk-mmcblk0 "$3" "$4" "$5"
  ntp_graph /srv/www/htdocs/piaware/$2-ntp-$4.png /var/lib/collectd/rrd/$1/ntpd "$3" "$4" "$5"
  net_fa_graph /srv/www/htdocs/piaware/$2-netfa-$4.png /var/lib/collectd/rrd/$1 "$3" "$4" "$5"
  tracks_graph /srv/www/htdocs/piaware/dump1090-$2-tracks-$4.png /var/lib/collectd/rrd/$1/dump1090-$2 "$3" "$4" "$5"
  predict_graph /srv/www/htdocs/piaware/predict.png /var/lib/collectd/rrd/$1/dump1090-$2 "$3" "$4" "$5"
  #metric_temp_graph /srv/www/htdocs/piaware/table-$2-core_temp-$4.png /var/lib/collectd/rrd/$1/table-$2 "$3" "$4" "$5"
  #imperial_temp_graph /srv/www/htdocs/piaware/table-$2-core_temp-$4.png /var/lib/collectd/rrd/$1/table-$2 "$3" "$4" "$5"
  #metric_range_graph /srv/www/htdocs/piaware/dump1090-$2-range-$4.png /var/lib/collectd/rrd/$1/dump1090-$2 "$3" "$4" "$5"
  imperial_range_graph /srv/www/htdocs/piaware/dump1090-$2-range-$4.png /var/lib/collectd/rrd/$1/dump1090-$2 "$3" "$4" "$5"
  signal_graph /srv/www/htdocs/piaware/dump1090-$2-signal-$4.png /var/lib/collectd/rrd/$1/dump1090-$2 "$3" "$4" "$5"
  #wireless_graph /srv/www/htdocs/piaware/$2-wifisignal-$4.png /var/lib/collectd/rrd/$1/table-$2 "$3" "$4" "$5"
  uptime_graph /srv/www/htdocs/piaware/$2-uptime-$4.png /var/lib/collectd/rrd/$1/uptime "$3" "$4" "$5"
}

# receiver_graphs host shortname longname period step
receiver_graphs() {
  common_graphs "$1" "$2" "$3" "$4" "$5"
  # Create the moving average graph for 24h period, not for other periods
  if [ $4  != "24h" ]
    then
      local_rate_graph /srv/www/htdocs/piaware/dump1090-$2-rate-$4.png /var/lib/collectd/rrd/$1/dump1090-$2 "$3" "$4" "$5"
    else
      local_rate_graph_24ma /srv/www/htdocs/piaware/dump1090-$2-rate-$4.png /var/lib/collectd/rrd/$1/dump1090-$2 "$3" "$4" "$5"

  fi
}

# Below are specific to my environment
hillsrv1_graphs() {
  cpu_only_graph /srv/www/htdocs/hillsrv1/$2-cpu-$4.png /var/lib/collectd/rrd/$1/cpu-0 "$3" "$4" "$5"
  memory_graph /srv/www/htdocs/hillsrv1/$2-memory-$4.png /var/lib/collectd/rrd/$1/memory "$3" "$4" "$5"
  df_graph /srv/www/htdocs/hillsrv1/$2-df-root-$4.png /var/lib/collectd/rrd/$1/df-root "$3" "$4" "$5"
  net_graph /srv/www/htdocs/hillsrv1/$2-eth0-$4.png /var/lib/collectd/rrd/$1/interface-eth0 "$3" "$4" "$5"
  bind_hillhome_qtypes_graph /srv/www/htdocs/hillsrv1/$2-bind-hillhome-qtypes-$4.png /var/lib/collectd/rrd/$1/bind-_default-qtypes "$3" "$4" "$5"
  bind_global_qtypes_graph /srv/www/htdocs/hillsrv1/$2-bind-global-qtypes-$4.png /var/lib/collectd/rrd/$1/bind-global-qtypes "$3" "$4" "$5"
  bind_global_queryresp_graph /srv/www/htdocs/hillsrv1/$2-bind-global-qresp-$4.png /var/lib/collectd/rrd/$1/bind-global-server_stats "$3" "$4" "$5"
  bind_global_serverrespcode_graph /srv/www/htdocs/hillsrv1/$2-bind-global-srvrcode-$4.png /var/lib/collectd/rrd/$1/bind-global-server_stats "$3" "$4" "$5"
  diskio_ops_graph /srv/www/htdocs/hillsrv1/$2-disk-ops-$4.png /var/lib/collectd/rrd/$1/disk-sda "$3" "$4" "$5"
  diskio_octets_graph /srv/www/htdocs/hillsrv1/$2-disk-octets-$4.png /var/lib/collectd/rrd/$1/disk-sda "$3" "$4" "$5"
  uptime_graph /srv/www/htdocs/hillsrv1/$2-uptime-$4.png /var/lib/collectd/rrd/$1/uptime "$3" "$4" "$5"
  ping_graph /srv/www/htdocs/hillsrv1/$2-pinglat-$4.png /var/lib/collectd/rrd/$1/ping "$3" "$4" "$5"
  openvpn_graph /srv/www/htdocs/hillsrv1/$2-openvpn-$4.png /var/lib/collectd/rrd/$1/openvpn-openvpn-status.log "$3" "$4" "$5"

}

period="$1"
step="$2"
nowlit=`date '+%m/%d/%y %H:%M %Z'`;
receiver_graphs piaware rpi "PiAware" "$period" "$step"
hillsrv1_graphs hillsrv1 hillsrv1 "Hillsrv1" "$period" "$step"

