#!/usr/bin/python3

from bs4 import BeautifulSoup
import requests
import sys
import subprocess

headers = {'Content-type': 'application/x-www-form-urlencoded; charset=utf-8'}
endpoint="https://doc.trilio.io:5000/8d92edd6-514d-4acd-90f6-694cb8d83336/0061K00000i9ORf"
result = subprocess.check_output("kubectl get ns tvk -o=jsonpath='{.metadata.uid}'", shell=True)
kubeid = result.decode("utf-8")
data = "kubescope=clusterscoped&kubeuid={0}".format(kubeid)
r = requests.post(endpoint, data=data, headers=headers)
contents=r.content
soup = BeautifulSoup(contents, 'lxml')
sys.stdout = open("license_file1.yaml", "w")
print(soup.body.find('div', attrs={'class':'yaml-content'}).text)
sys.stdout.close()
result = subprocess.check_output("kubectl apply -f license_file1.yaml --namespace tvk", shell=True)

