#!/bin/bash
# watch your irssi fnotify file for new messages to notify you of...
# Copyright (C) 2012-2013  James Shubin
# Written by James Shubin <james@shubin.ca>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# this requires my irssi fnotify.pl script to be loaded in your remote irssi...
# this requires your ~/.ssh/config LocalCommand to run this script with --start

#
#	globals
#
FILE='~/.irssi/fnotify'					# fnotify on server
NOTIFY=`which notify-send`
#NOTIFY='/bin/echo'					# useful for debugging!
BEEP="`which paplay` /usr/share/sounds/purple/receive.wav"	# loud!
#BEEP='/usr/bin/beep'
COUNT="/tmp/`basename $0`.count"			# local in your /tmp/
FIFO="/tmp/`basename $0`.fifo"				# local in your /tmp/

if [ "$1" == '--help' ]; then
	# this method should be used from LocalCommand in ~/.ssh/config
	echo "usage: ./"`basename $0`" [--start] <hostname> [--ppid <ppid>]"
	exit 1
fi

if [ "$1" == '--start' ]; then
	shift 1
	SERVER=$1
	# $PPID is pid of the main calling, ssh command
	{ `$0 "$SERVER" --ppid "$PPID" &> /dev/null`; } &	# daemonize...
	exit		# LocalCommand from ~/.ssh/config should not block
fi

# assume we're daemonized or running interactively...
SERVER=$1
shift 1
if [ "$SERVER" == '' ]; then
	echo "usage: ./"`basename $0`" <hostname> [--ppid <ppid>]"
	exit 1
fi

WAIT=''
if [ "$1" == '--ppid' ]; then
	WAIT="$2"	# passed in $PPID
fi

# thanks to bahamas10 in #bash for giving me the idea to use a fifo...
rm -f $FIFO
mkfifo $FIFO
ssh $SERVER "tail -F $FILE 2> /dev/null" > $FIFO &
SSH_PID=$!	# save the pid
(
	i=0
	echo 0 > $COUNT
	# TODO: should i use sed to get rid of invalid characters?
	cat $FIFO | while
	read network from msg; do
		((i++))				# count messages
		echo $i > $COUNT		# XXX: hack
		xmsg=`/bin/echo "${msg}" | /usr/bin/recode html..unicode..ascii..html`	# escape
		if [ ${network:0:1} = "#" ]; then
			fmsg=$(echo $xmsg | sed -e 's/^: //g')
			$NOTIFY -i gtk-dialog-info -t 300000 -- "${network}(${from})" "${fmsg}";
		else
			$NOTIFY -i gtk-dialog-info -t 300000 -- "pvt(${network})" "${from} ${xmsg}";
		fi
		$BEEP
	done
) &

if [ "$WAIT" != '' ]; then
	# TODO: sadly inotifywait /proc/$WAIT/ won't work for /proc, so we poll
	while kill -0 2> /dev/null "$WAIT"; do
		sleep 1s
	done
fi

kill $SSH_PID					# kill ssh process to clean up!
#kill -9 $SSH_PID
if [ -p $FIFO ]; then
	rm $FIFO
fi

C=`cat $COUNT`
if [ -e $COUNT ]; then
	rm $COUNT
fi

# truncate viewed messages...
if [ $C -gt 0 ]; then
	ssh $SERVER "tail -n +$((C+1)) $FILE | tee $FILE > /dev/null"
fi

exit

