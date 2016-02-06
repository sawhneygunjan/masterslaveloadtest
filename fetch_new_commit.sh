#!/bin/bash

_master_pem="/var/lib/jenkins/keys/sl"
_master_dir="/home/ubuntu/loadtest_files/"
_master_ip="10.0.2.22"
_counter_csv=0
_counter_conf=0
_files=($(ls -t /var/lib/jenkins/jobs/Loadtest/workspace | head -2))

for _itr in ${_files[@]}
do
	if [[ $_itr == *.csv ]] 
	then
		_counter_csv=`expr $_counter_csv + 1`

	elif [[ $_itr == *.conf ]]
	then
		  _counter_conf=`expr $_counter_conf + 1`
	fi
done

if [ $_counter_csv -eq 1 ] && [ $_counter_conf -eq 1 ]
then
	_csv_file=`ls -t /var/lib/jenkins/jobs/Loadtest/workspace/*.csv | head -1`
	echo "Txt file : $_csv_file"
	_conf_file=`ls -t /var/lib/jenkins/jobs/Loadtest/workspace/*.conf | head -1`
	echo "Conf file : $_conf_file"

	_csv_time=`stat -c %y $_csv_file`
	echo "Txt time : $_csv_time"
	_conf_time=`stat -c %y $_conf_file`
	echo "Conf time : $_conf_time"

	if [ "$_csv_time" == "$_conf_time" ]
	then
		echo "**********************************************"
		echo "Calling load test with parameters in conf file"
		echo "**********************************************"
		scp -i $_master_pem $_csv_file ubuntu@$_master_ip:$_master_dir
		scp -i $_master_pem $_conf_file ubuntu@$_master_ip:$_master_dir
	else
		echo "[ERROR] Please commit csv and it's respective conf file(together)"
		exit
	fi
else
	echo "[ERROR] Wrong Commit !! Csv and Conf file required"
fi

