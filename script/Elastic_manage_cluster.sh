#!/bin/sh
#VERSION=0.1

ELASTICURL="http://localhost:9200"

#CURL="curl -s --cacert /REP/CA.cer"
CURL="curl -s -k"

COMMAND=${1:-usage}

usage() {
        echo -e "\nUsage:  Elastic_manage_cluster.sh COMMAND \n\nCommands: \
                \n\t- cluster : print information about cluster \
                \n\t- indices : print information about indices \
        \n"
}

usage_command() {
        echo -e "\nUsage:  Elastic_manage_cluster.sh $COMMAND \n\nArgs:"
        echo "indicesusage"
}

cluster() {
        echo "NA"
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
                LIST=`$CURL "${ELASTICURL}/_cat/indices?v&s=store.size:asc&h=index" | grep -wE "^$OPTIONS"`
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

indices(){
        ARG=${1:-usage_command}
        OPTIONS=${2}
        case $ARG in
                list)
                        $CURL "${ELASTICURL}/_cat/indices"
                        EXIT=$?;;
                close|open)
                        close_open $ARG $OPTIONS
                        EXIT=$?;;
                *)
                        usage_command $ARG;;
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
