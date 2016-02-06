#!/bin/bash

kill -9 `ps -eaf | grep jmeter | awk '{print $2}' | xargs`
nohup bash /usr/share/jmeter/bin/jmeter-server >/dev/null 2>&1 &

