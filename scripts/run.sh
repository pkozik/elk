#!/bin/bash

ES_HOME=/var/lib/mesos/elk

type=$1
DATA_PATH=${ES_HOME}/${type}

if [[ ! -d $DATA_PATH ]]; then
	mkdir -p $DATA_PATH/data  $DATA_PATH/log
fi

chmod 777 $DATA_PATH/data $DATA_PATH/log
docker stop es_${type}
docker rm es_${type}


# master node
if [[ $type == "master" ]]; then
	docker run \
		-d \
		--name "es_${type}" \
		-e "NODE_NAME=${HOSTNAME}" \
		-e "network.publish_host=${HOSTNAME}" \
		-e "bootstrap.memory_lock=true" \
		-e "transport.tcp.port=9300" \
		-e "CLUSTER_NAME=mantl" \
		-e "NODE_MASTER=true" \
		-e "NODE_DATA=true" \
		-e "NETWORK_HOST=_site_" \
		-e "HTTP_ENABLE=false" \
		-e "ES_JAVA_OPTS=-Xms2g -Xmx2g" \
		-e "NUMBER_OF_SHARDS=1" \
		-e "NUMBER_OF_REPLICAS=1" \
		-e "NUMBER_OF_MASTERS=1" \
		-e "DISCOVERY_SERVICE=mantl-worker-001,mantl-worker-002,mantl-worker-004" \
		-e "xpack.security.enabled=false" \
		-p 9300:9300 \
		--cap-add=IPC_LOCK \
		--memory=4g \
		--memory-swap=4g \
		--memory-swappiness=0 \
		--ulimit "nofile=65536:65536" \
		--ulimit "memlock=-1:-1" \
		--ulimit "nproc=2048:2048" \
		-v $DATA_PATH:/data \
		csf/elk_e:5.4

# data node
elif [[ $type == "data" ]]; then
	docker run \
		-d \
		--name "es_${type}" \
		-e "NODE_NAME=${HOSTNAME}" \
		-e "network.publish_host=${HOSTNAME}" \
		-e "transport.tcp.port=9300" \
		-e "bootstrap.memory_lock=true" \
		-e "CLUSTER_NAME=mantl" \
		-e "NODE_MASTER=false" \
		-e "NODE_DATA=true" \
		-e "NETWORK_HOST=_site_" \
		-e "HTTP_ENABLE=false" \
		-e "ES_JAVA_OPTS=-Xms2g -Xmx2g" \
		-e "NUMBER_OF_SHARDS=1" \
		-e "NUMBER_OF_REPLICAS=1" \
		-e "NUMBER_OF_MASTERS=1" \
		-e "DISCOVERY_SERVICE=mantl-worker-001,mantl-worker-002,mantl-worker-003" \
		-p 9300:9300 \
		--memory=4g \
		--ulimit "nofile=65536:65536" \
		--ulimit "memlock=-1:-1" \
		--ulimit "nproc=2048:2048" \
		-v $DATA_PATH:/data \
		csf/elk_e:5.4

# client node
elif [[ $type == "client" ]]; then
	docker run \
		-d \
		--name "es_${type}" \
		-e "NODE_NAME=${HOSTNAME}" \
		-e "network.publish_host=${HOSTNAME}" \
		-e "transport.tcp.port=9500" \
		-e "CLUSTER_NAME=mantl" \
		-e "NODE_MASTER=false" \
		-e "NODE_DATA=false" \
		-e "NETWORK_HOST=_site_" \
		-e "HTTP_ENABLE=true" \
		-e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
		-e "DISCOVERY_SERVICE=mantl-worker-001:9300,mantl-worker-002:9300,mantl-worker-003:9300" \
		-p 9500:9500 \
		-p 9200:9200 \
		--memory=2g \
		-v $DATA_PATH:/data \
		csf/elk_e:5.4
		
fi		


docker logs -f 	es_${type}
