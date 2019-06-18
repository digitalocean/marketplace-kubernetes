#!/bin/sh

#This scripts checks if the Prometheus and Grafana pod are in running status or not.

#WAIT_TIME
#ITERATIONS
#PROMETHEUS_ITR
#GRAFANA_ITR

WAIT_TIME="5s"
ITERATIONS=60
PROMETHEUS_ITR=0
GRAFANA_ITR=0


#Checking Prometheus
while [ $PROMETHEUS_ITR -lt  $ITERATIONS ]; do
    kubectl rollout status deployment prometheus-server -n prometheus
    if [ $? -eq 0 ];then
        break
    fi
    let PROMETHEUS_ITR+=1
    sleep $WAIT_TIME
done
if [ $PROMETHEUS_ITR -eq $ITERATIONS ]; then
    exit 1
fi

#Checking Grafana
while [ $GRAFANA_ITR -lt  $ITERATIONS ]; do
    kubectl rollout status deployment grafana -n grafana
    if [ $? -eq 0 ];then
        break
    fi
    let GRAFANA_ITR+=1
    sleep $WAIT_TIME
done
if [ $GRAFANA_ITR -eq $ITERATIONS ]; then
    exit 1
fi


