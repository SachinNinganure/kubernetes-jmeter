#!/usr/bin/env bash
#Create multiple Jmeter namespaces on an existing kuberntes cluster
#Author: Sachin Ninganure
working_dir=`pwd`
tenant=`date +%d%H%M%S`
echo "checking if oc is present"

if ! hash oc 2>/dev/null
then
    echo "'oc' was not found in PATH"
    echo "Kindly ensure that you can acces an existing OpenShift cluster via oc"
    exit
fi

oc version

echo "Current list of projects on the OpenShift cluster:"

echo

oc get project | grep -v NAME | awk '{print $1}'

echo

#echo "Enter the name of the new project unique name, this will be used to create the namespace"
#read tenant
#echo

#Check If namespace exists

echo $tenant
oc get project $tenant > /dev/null 2>&1

if [ $? -eq 0 ]
then
  echo "Project $tenant already exists, please select a unique name"
  echo "Current list of projects on the OpenShift cluster"
  sleep 2

 oc get project | grep -v NAME | awk '{print $1}'
  exit 1
fi

echo
echo "Creating project: $tenant"

oc new-project $tenant --description="jmeter cluster for loadtesting" --display-name="sninganu-loadtesting"


echo "Project $tenant has been created"

oc project $tenant

echo "setting perms"
oc adm policy add-scc-to-user privileged -n $tenant -z default

echo "Creating Jmeter slave nodes"

nodes=`oc get node | egrep -v "master|NAME" | wc -l`

echo "Number of worker nodes on this cluster are " $nodes

echo "Creating Jmeter slave replicas and service"


oc create -f jmeter_slaves_deploymentconfig.yaml

oc create -f jmeter_slaves_svc.yaml

echo "Creating Jmeter Master"

oc create -f jmeter_master_configmap.yaml

oc create -f jmeter_master_deploymentconfig.yaml


echo "Creating Influxdb and the service"

oc create -f jmeter_influxdb_configmap.yaml

oc create -f jmeter_influxdb_deploymentconfig.yaml

oc create -f jmeter_influxdb_svc.yaml

echo "Creating Grafana Deployment"
oc create -f jmeter_grafana_deploy.yaml
oc create -f jmeter_grafana_svc.yaml

echo "Printout Of the $tenant Objects"

echo

oc get all -o wide

echo project= $tenant > $working_dir/tenant_export
