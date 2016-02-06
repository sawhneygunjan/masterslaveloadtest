import glob, os
import shlex
import subprocess
from subprocess import Popen
import sys
import time

"""File arguments"""
_conf = sorted(glob.glob('/home/ubuntu/loadtest_files/*.conf'), key=os.path.getctime)
newest = _conf[-1]
array=[]
_conf_file=open(newest)
for line in _conf_file:
	for word in line.split(): 
		array.append(word)
	
if len(array) == 5:
	users = array[0]
	ramp_up = array[1]
	loop_count = array[2]
	txt_file = array[3]
	output_file = array[4]
else:
	print "[ERROR] Conf file should contain 5 parameters"
	exit()


"""Funtion to clean html result directory"""

def remove_file():
    filelist = glob.glob("/home/ubuntu/loadtest_files/*")
    for f in filelist:
        os.remove(f)
    return 1


"""Function to run the load test """
def run_loadtest(users, ramp_up, loop_count, txt_file, output_file):
	command = "bash /home/ubuntu/scripts/masterSlaveLoadTest.sh %d %d %d %s %s" % ( int(users) , int(ramp_up) , int(loop_count) , str(txt_file) , str(output_file)) 
	p = subprocess.Popen(command , shell=True)
	p.wait()
	if p.returncode == 1:
		print "*********************************"
                print "Aborting!! Last Load Test Failed"
                print "*********************************"
		exit()
	else:
		file_object = open('statusFile', 'w')
                file_object.write('True')

run_loadtest(users, ramp_up, loop_count, txt_file, output_file)

iterator = 1
while iterator <=1:
	file_object = open('statusFile')
	first=file_object.readline()
	if first == "True":
		users = 3*int(users)
		ramp_up = 3*int(ramp_up)
		run_loadtest(users, ramp_up, loop_count , txt_file , output_file)
		iterator = iterator + 1
        else:
		print "*********************************"
		print "Aborting!! Last Load Test Failed"
		print "*********************************"
		iterator = iterator + 1
                break

