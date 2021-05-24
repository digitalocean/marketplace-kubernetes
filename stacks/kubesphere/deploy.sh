#!/bin/sh

set -e

kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.1.0/kubesphere-installer.yaml
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.1.0/cluster-configuration.yaml

sleep 2s

function check_ks_installer(){
   while true
   do
      if [[ "`kubectl get pod -A|grep  ks-installer|awk '{print $4}'`" == "Running" ]];
          then
                timeout 1200s kubectl logs -f -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') | sed -e "{/Password: P@88w0rd/q}"
               break
      elif [[ "`kubectl get pod -A|grep  ks-installer|awk '{print $4}'`" == "ContainerCreating" ]];
          then
                echo   "ks-installer is starting,please wait"
                sleep 120s
         
      else
          echo "ks-installer not output 'Welcome to KubeSphere'"
          sleep 20s
      fi
  done
}


function check_kubesphere_pod(){
    for ((i=0;i<13;i++))
    do
       sleep 5s
       Status=`kubectl get pod -A| grep -E 'Running|Completed' |grep kubesphere| awk '{print $4}' | wc -l`
       Allpod=`kubectl get pod -A| grep kubesphere| awk '{print $4}' | wc -l`
       if [[ $Status == $Allpod ]]
          then
            i=$((i+1))
       else
            i=0
            kubectl get pod -A | grep -vE 'Running|Completed'
       fi
        sleep 1
    done
}



check_ks_installer
echo -e  "\n"
echo -e  $(date) " - ks-installer Complete \n"

check_kubesphere_pod
echo -e  $(date) " - KubeSphere Complete \n"
