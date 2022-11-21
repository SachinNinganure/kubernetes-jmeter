#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir=`pwd`

#Get namesapce variable
tenant=`awk '{print $NF}' $working_dir/tenant_export`

#read -p 'Enter path to the jmx file ' jmx

#if [ ! -f "$jmx" ];
#then
 #   echo "Test script file was not found in PATH"
  #  echo "Kindly check and input the correct file path"
   # exit
#fi

#Get Master pod details


master_pod=`oc get pod  | grep jmeter-master|grep Running| awk '{print $1}'`

oc cp cloudssky.jmx -n $tenant $master_pod:/jmeter/cloudssky.jmx
oc cp load_test2 -n $tenant $master_pod:/jmeter/load_test2
#oc cp cloudssky.jmx $master_pod:/jmeter/cloudssky.jmx
#oc cp load_test2 $master_pod:/jmeter/load_test2
oc exec  -n $tenant $master_pod -- chmod 755 /jmeter/load_test2
echo "Starting Jmeter load test....!"

oc exec  $master_pod -- /bin/bash /jmeter/load_test2 /jmeter/cloudssky.jmx
#oc exec -ti $master_pod -- /bin/bash /jmeter/load_test1 cloudssky.jmx
