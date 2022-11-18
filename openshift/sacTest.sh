#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir=`pwd`


read -p 'Enter path to the jmx file ' jmx

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi


master_pod=`oc get pod  | grep jmeter-master | awk 'NR==1{print $1}'`


#oc cp $jmx $master_pod:/$jmx

oc cp cloudssky.jmx $master_pod:/jmeter/cloudssky.jmx

## Echo Starting Jmeter load test

oc exec  $master_pod -- /bin/bash /jmeter/load_test cloudssky.jmx
#oc exec -ti $master_pod -- /bin/bash /jmeter/load_test1 cloudssky.jmx
