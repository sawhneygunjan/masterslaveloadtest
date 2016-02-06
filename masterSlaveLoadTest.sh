#!/bin/bash

_jmeter_bin_folder="/home/ubuntu/apache-jmeter-2.8/bin"
_jmx_folder="/home/ubuntu/loadtest_files"
_ant_folder="/home/ubuntu/ant_lib"
_s3_bucket="s3://com.sony.jmeter/output/"
_s3_bucket_link="https://s3-ap-southeast-1.amazonaws.com/com.sony.jmeter/output"
_slave_ip1="10.0.2.101"
_slave_ip2="10.0.2.122"
_jmx_file="/home/ubuntu/jmx_files/CSVReplica1.jmx"
_permanent_jmx_file="/home/ubuntu/CSVReplica1.jmx"
_slave_pem="/home/ubuntu/pem/sl"
_ant_file="/home/ubuntu/auto_loadtest.xml"
_remote_slave_ips="$_slave_ip1,$_slave_ip2"
_output_file_folder="$_ant_folder/lib"
_date=`date +%F-%T`

users=$1
ramp_up=$2
loop_count=$3
txt_file=$4
output_file=$5-$_date

########################################Cleaning output folder#################################################
cd $_output_file_folder

rm -f *.html
rm -f *.xml

########################################Jmx File################################################################
rm -f $_jmx_file
cp $_permanent_jmx_file $_jmx_file
sed -i "s/loop_count/$loop_count/" $_jmx_file 
sed -i "s/users/$users/" $_jmx_file 
sed -i "s/ramp_up/$ramp_up/" $_jmx_file
sed -i "s/URLS_FILE_CSV/$txt_file/" $_jmx_file

########################################Running Load Test########################################################
echo "[Users] : $users"
echo "[Ramp_up] : $ramp_up"
echo "[Loop_count] : $loop_count"
echo "[Txt_file] : $txt_file"
echo "[Output_file] : $output_file"

scp -oStrictHostKeyChecking=no -i $_slave_pem $_jmx_folder/$txt_file ubuntu@$_slave_ip1:/home/ubuntu/ 
scp -oStrictHostKeyChecking=no -i $_slave_pem $_jmx_folder/$txt_file ubuntu@$_slave_ip2:/home/ubuntu/

echo "[ECHO] $_jmeter_bin_folder/jmeter -n -t $_jmx_file -R $_remote_slave_ips -l $_output_file_folder/$output_file.xml"
$_jmeter_bin_folder/jmeter -n -t $_jmx_file -R $_remote_slave_ips -l $_output_file_folder/$output_file.xml

_count=`grep 'rc="50*"' $_output_file_folder/$output_file.xml | wc -l`
if [ $_count -gt 0 ]
then
	
	cd $_output_file_folder
	cp $_ant_file .
	sed -i "s/outputFile/$output_file/g" auto_loadtest.xml
	ant -f auto_loadtest.xml
	aws s3 cp $_output_file_folder/$output_file.html $_s3_bucket
	rm -f auto_loadtest.xml
	echo "*****************LINK FOR THIS LOADTEST RESULT************************ "
	echo "$_s3_bucket_link/$output_file.html"
	echo "********************************************************************** "
	exit 1

else
	echo "*************************************"
	echo "FOR `expr 2 \* $users` USERS LOAD TEST PASSED"
	echo "*************************************"
fi

sleep 300

