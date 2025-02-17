╰$ helm install zookeeper . -n kafka --create-namespace
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
NAME: zookeeper
LAST DEPLOYED: Thu Feb 13 13:09:16 2025
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








$ helm upgrade --install kafka . -n kafka
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/ajay/kubeconfig/npci
Release "kafka" has been upgraded. Happy Helming!
NAME: kafka
LAST DEPLOYED: Thu Feb 13 13:26:54 2025
NAMESPACE: kafka
STATUS: deployed
REVISION: 2
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



