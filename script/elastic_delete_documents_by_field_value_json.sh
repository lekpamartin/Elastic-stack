#!/bin/sh
#Martin LEKPA
#VERSION=0.1


#CURL="curl -s --cacert /REP/CA.cer"
CURL="curl -s -k"

LOG="$(dirname $0)/logs/elastic_delete_documents_by_field_value_json.$(date +%Y.%V)"
JSON=`cat $(dirname $0)/elastic_delete_documents_by_field_value_json.json`

echo "" > $LOG

if jq -e . >/dev/null 2>&1 <<<"$JSON"; then
	echo "Parsed JSON successfully and got something other than false/null" >> $LOG
else
	echo -e "\n\tFailed to parse JSON ($(dirname $0)/elastic_delete_documents.json) with jq, or got false/null\n" >> $LOG
	exit 1
fi

DEFAULTTARGETWEEK=`echo $JSON | jq -r '.delay'`

ELASTICURL="http://localhost:9200"
INDEXLIST="index1 index2"


for i in $INDEXLIST; do
	echo -e "\n * $i" >> $LOG
	FIELDLIST=`echo $JSON | jq -r ".index.$i[].field"`
	for j in $FIELDLIST; do
		VALUELIST=`echo $JSON | jq -r ".index.$i[] | select(.field == \"$j\") | .value" | jq -r '.[]'`
		TARGETWEEK=`echo $JSON | jq -r ".index.$i[] | select(.field == \"$j\") | .delay" `
		if [ "${TARGETWEEK}" == "null" ]; then
			TARGETWEEK=`date +%Y.%V -d "$DEFAULTTARGETWEEK"`
		else
			TARGETWEEK=`date +%Y.%V -d "$TARGETWEEK"`
		fi
		echo -e "\n\t - $j (${TARGETWEEK})" >> $LOG
		for k in $VALUELIST; do
			echo -e "\n\n\t\t . $k\n\t\t\t Deleting..." >> $LOG
			$CURL "${ELASTICURL}/$i-${TARGETWEEK}/_delete_by_query" -XPOST -H "Content-Type: application/json" -d "{ \"query\": { \"match\": { \"$j\": \"$k\" } } }" >> $LOG
		done
	done
	echo -e "\n\n Merging $i-${TARGETWEEK}..." >> $LOG
	$CURL "${ELASTICURL}/$i-${TARGETWEEK}/_forcemerge?only_expunge_deletes=true" -XPOST >> $LOG
done
