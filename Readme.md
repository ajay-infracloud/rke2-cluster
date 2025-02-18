### Note : For this POC we've used AWS EC2 instances to be used with RKE2 to create a k8s cluster.


# K8s cluster creation with RKE2.

1. Export AWS creds.
2. Go to terraform directory and run terraform plan.
3. Once you validate the resources, run terraform apply.

This will bring a 4 node RKE2 cluster with one master and 3 worker nodes.



4. Copy kubeconfig file from k8s master node /etc/rancher/rke2/rke2.yaml to your local system.

5. Replace the API server address from 127.0.0.1 to EIP of the master server.

6. Run `kubectl get nodes` and it should work.


# Install EBS CSI Driver for automatic volume provisioning using AWS Elastic Block Storage.

`kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.39"`
Check if all the csi pods are up and running.

## Create a default storage class.

kubectl apply -f sc.yaml

### Confirm if you are able to provision pvc using a sample pod given inside pvc.yaml.

`kubectl apply -f pvc.yaml`

Delete once confirmed.
`kubectl delete -f pvc.yaml `



# Install Zookeeper using helm chart.

### Go to zookeeper directory inside helm folder, and run below command.


`helm install zookeeper . -n kafka --create-namespace`
```
$ helm install zookeeper . -n kafka --create-namespace
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
NAME: zookeeper
LAST DEPLOYED: Tue Feb 18 00:14:04 2025
NAMESPACE: kafka
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: zookeeper
CHART VERSION: 13.7.3
APP VERSION: 3.9.3

Did you know there are enterprise versions of the Bitnami catalog? For enhanced secure software supply chain features, unlimited pulls from Docker, LTS support, or application customization, see Bitnami Premium or Tanzu Application Catalog. See https://www.arrow.com/globalecs/na/vendors/bitnami for more information.

** Please be patient while the chart is being deployed **

ZooKeeper can be accessed via port 2181 on the following DNS name from within your cluster:

    zookeeper.kafka.svc.cluster.local

To connect to your ZooKeeper server run the following commands:

    export POD_NAME=$(kubectl get pods --namespace kafka -l "app.kubernetes.io/name=zookeeper,app.kubernetes.io/instance=zookeeper,app.kubernetes.io/component=zookeeper" -o jsonpath="{.items[0].metadata.name}")
    kubectl exec -it $POD_NAME -- zkCli.sh

To connect to your ZooKeeper server from outside the cluster execute the following commands:

    kubectl port-forward --namespace kafka svc/zookeeper 2181:2181 &
    zkCli.sh 127.0.0.1:2181

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - resources
  - tls.resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
╭─ajay@ajay-joshi in ~/infracloud/npci/helm/zookeeper 

```


#### Once Zookeeper is installed, Make changes to values.yaml and set externalzookeeper address to zookeeper service.

# Install Kafka
### Go to kafka folder inside helm folder, and run below command.


`helm upgrade --install kafka . -n kafka`

```
$ helm install kafka . -n kafka                       
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
NAME: kafka
LAST DEPLOYED: Tue Feb 18 00:16:02 2025
NAMESPACE: kafka
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: kafka
CHART VERSION: 31.3.1
APP VERSION: 3.9.0

Did you know there are enterprise versions of the Bitnami catalog? For enhanced secure software supply chain features, unlimited pulls from Docker, LTS support, or application customization, see Bitnami Premium or Tanzu Application Catalog. See https://www.arrow.com/globalecs/na/vendors/bitnami for more information.

** Please be patient while the chart is being deployed **

Kafka can be accessed by consumers via port 9092 on the following DNS name from within your cluster:

    kafka.kafka.svc.cluster.local

Each Kafka broker can be accessed by producers via port 9092 on the following DNS name(s) from within your cluster:

    kafka-broker-0.kafka-broker-headless.kafka.svc.cluster.local:9092
    kafka-broker-1.kafka-broker-headless.kafka.svc.cluster.local:9092
    kafka-broker-2.kafka-broker-headless.kafka.svc.cluster.local:9092

The CLIENT listener for Kafka client connections from within your cluster have been configured with the following security settings:
    - SASL authentication

To connect a client to your Kafka, you need to create the 'client.properties' configuration files with the content below:

security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-256
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="user1" \
    password="$(kubectl get secret kafka-user-passwords --namespace kafka -o jsonpath='{.data.client-passwords}' | base64 -d | cut -d , -f 1)";

To create a pod that you can use as a Kafka client run the following commands:

    kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.9.0-debian-12-r6 --namespace kafka --command -- sleep infinity
    kubectl cp --namespace kafka /path/to/client.properties kafka-client:/tmp/client.properties
    kubectl exec --tty -i kafka-client --namespace kafka -- bash

    PRODUCER:
        kafka-console-producer.sh \
            --producer.config /tmp/client.properties \
            --bootstrap-server kafka.kafka.svc.cluster.local:9092 \
            --topic test

    CONSUMER:
        kafka-console-consumer.sh \
            --consumer.config /tmp/client.properties \
            --bootstrap-server kafka.kafka.svc.cluster.local:9092 \
            --topic test \
            --from-beginning

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - broker.resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
╭─ajay@ajay-joshi in ~/infracloud/npci/helm/kafka 


```

#### Validate all the pods are running inside kafka namespace.

### Run a kafka client and, use kafka producer and consumer to test as described above.


## Screenshot in Docx file (Npci.docx)

# Other Installations

I also installed rancher UI to deploy and manage resources.

```

╰$ kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.11.0 \
  --set installCRDs=true
namespace/cert-manager created
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ajay/kubeconfig/npci

NAME: cert-manager
LAST DEPLOYED: Tue Feb 18 00:02:10 2025
NAMESPACE: cert-manager
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
cert-manager v1.11.0 has been deployed successfully!

In order to begin issuing certificates, you will need to set up a ClusterIssuer
or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).

More information on the different types of issuers and how to configure them
can be found in our documentation:

https://cert-manager.io/docs/configuration/

For information on how to configure cert-manager to automatically provision
Certificates for Ingress resources, take a look at the `ingress-shim`
documentation:

https://cert-manager.io/docs/usage/ingress/
╭─ajay@ajay-joshi in ~/infracloud/npci 




╭─ajay@ajay-joshi in ~/infracloud/npci 
╰$ helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --create-namespace \
  --set hostname=rancher.3.134.68.33.npci.io \
  --set ingress.enabled=true \
  --set bootstrapPassword=bootStrapAllTheThings \
  --set ingress.host=3.134.68.33
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
Release "rancher" does not exist. Installing it now.
NAME: rancher
LAST DEPLOYED: Tue Feb 18 00:04:26 2025
NAMESPACE: cattle-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Rancher Server has been installed.

NOTE: Rancher may take several minutes to fully initialize. Please standby while Certificates are being issued, Containers are started and the Ingress rule comes up.

Check out our docs at https://rancher.com/docs/

If you provided your own bootstrap password during installation, browse to https://rancher.3.134.68.33.npci.io to get started.

If this is the first time you installed Rancher, get started by running this command and clicking the URL it generates:


echo https://rancher.3.134.68.33.npci.io/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')

To get just the bootstrap password on its own, run:

kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'


Happy Containering!
╭─ajay@ajay-joshi in ~/infracloud/npci 


$ kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'
bootStrapAllTheThings
╭─ajay@ajay-joshi in ~/infracloud/npci 
╰$ 
```



# Encountered Issues:

### 1. Issue with coredns name resolution.
For some reason, my pods were not able to resolve dns. Due to this, there were some intermittent issues with EBS provisioning and other pods provisioning which required EC2 metadata.

There were some github issue around this issue and I got stuck into one direction only.

`https://github.com/rancher/rke2/discussions/1767`

I changed the CNI to calico instead of canal(default) by making come changes in rke2 config, even then I was not able to move forward.

But after looking closely at all possible causes, it turned out that issue was due to network port connectivity. Allowed defined port in rke2 installation, and worked fine post that.


