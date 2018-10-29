#!/bin/sh
#VERSION=0.1

ELASTICURL="http://localhost:9200"

#CURL="curl -s --cacert /REP/CA.cer"
CURL="curl -s -k"

COMMAND=${1:-usage}

usage() {
        echo -e "\nUsage:  Elastic_manage_cluster.sh COMMAND ARG OPTION\n\nCommands: \
		\n\t- cluster : print information about cluster. \
			\n\t\tArgs: \
				\n\t\t\t- nodes : print info of cluster's node\
				\n\t\t\t- status : status of the cluster \
			\n\t\tOptions: \
				\n\t\t\tNA
		\n\n\t- indices : print information about indices. \
			\n\t\tArgs: \
				\n\t\t\t- list : list one or more indices. No options \
				\n\t\t\t- close : close one or more indices. \
				\n\t\t\t- health : print health status of one or more indices. \
				\n\t\t\t- open : open one or more indices. \
				\n\t\t\t- status : status of one or more indices. \
				\n\t\t\t- store.size|pri.store.size : print size of one or more indices. \
			\n\t\tOptions: \
				\n\t\t\t- _all : for all indices. Only for open and close. \
				\n\t\t\t- indice : name of an index \
				\n\t\t\t- regex : regex matching or or more (starting with)\

	\n"
}


cluster() {
	ARG=${1:-usage}
	OPTIONS=$2
	case $ARG in
		status)
			$CURL "${ELASTICURL}/_cluster/health"
			EXIT=$?;;
		nodes)
			$CURL "${ELASTICURL}/_nodes/stats"
			EXIT=$?;;
		*)
			usage $ARG;;
	esac
	
}

close_open() {
	ACTION=$1
	OPTIONS=$2
	if [ "$OPTIONS" == "_all" ]; then
		LIST="All indices"
		echo -en "\nConfirm $ACTION for ${LIST} ? [y/n] : "
		read CONFIRM
		if [ $CONFIRM == "y" ]; then
			$CURL "${ELASTICURL}/$OPTIONS/_$ACTION" -XPOST
		else
			echo "Aborted by user"
		fi
	else
		LIST=`$CURL "${ELASTICURL}/_cat/indices/$OPTIONS?v&s=store.size:asc&h=index"`
		echo -en "\nConfirm $ACTION for $OPTIONS correponding to indices \n\n${LIST}\n\n [y/n] : "
		read CONFIRM
		if [ $CONFIRM == "y" ]; then
			for i in ${LIST}; do
				echo -en "\n- $i :"
				$CURL "${ELASTICURL}/$i/_$ACTION" -XPOST
			done
		else
			echo "Aborted by user"
		fi
	fi
	echo -e "\n"
			
}

indices_list_status_size() {
	ACTION=$1
	OPTIONS=$2
	if [ "$ACTION" == "list" ]; then
		PARAMS="?v"
	else
		PARAMS="?h=index,$ACTION"
	fi

	if [ "$OPTIONS" == "" ]; then
		$CURL "${ELASTICURL}/_cat/indices$PARAMS"
		EXIT=$?
	else
		$CURL "${ELASTICURL}/_cat/indices/$OPTIONS$PARAMS"
		EXIT=$?
	fi
}

indices(){
	ARG=${1:-usage}
	OPTIONS=${2}
	case $ARG in
		list|status|health|store.size|pri.store.size)
			indices_list_status_size $ARG $OPTIONS
			EXIT=$?;;
		close|open)
			close_open $ARG $OPTIONS
			EXIT=$?;;
		*)
			usage $ARG;;
	esac
	exit $EXIT
		
}

case $COMMAND in
	cluster)
		cluster ${@:2};;
	indices)
		indices ${@:2};;
	*)
		usage
		exit 1;;
esac
