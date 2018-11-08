#!/bin/sh
#Martin LEKPA
#VERSION=0.1


#CURL="curl -s --cacert /REP/CA.cer"
CURL="curl -s -k"

JSON=`cat $(dirname $0)/elastic_delete_documents_by_field_value_json.json`

if jq -e . >/dev/null 2>&1 <<<"$JSON"; then
	echo "Parsed JSON successfully and got something other than false/null"
else
	echo -e "\n\tFailed to parse JSON ($(dirname $0)/elastic_delete_documents.json) with jq, or got false/null\n"
	exit 1
fi

DEFAULTTARGETWEEK=`echo $JSON | jq -r '.delay'`

ELASTICURL="http://localhost:9200"
INDEXLIST="index1 index2"


for i in $INDEXLIST; do
	echo -e "\n * $i"
	FIELDLIST=`echo $JSON | jq -r ".index.$i[].field"`
	for j in $FIELDLIST; do
		VALUELIST=`echo $JSON | jq -r ".index.$i[] | select(.field == \"$j\") | .value" | jq -r '.[]'`
		TARGETWEEK=`echo $JSON | jq -r ".index.$i[] | select(.field == \"$j\") | .delay" `
		if [ "${TARGETWEEK}" == "null" ]; then
			TARGETWEEK=`date +%Y.%V -d "$DEFAULTTARGETWEEK"`
		else
			TARGETWEEK=`date +%Y.%V -d "$TARGETWEEK"`
		fi
		echo -e "\n\t - $j (${TARGETWEEK})"
		for k in $VALUELIST; do
			echo -e "\n\t\t . $k"
			$CURL "${ELASTICURL}/$i-${TARGETWEEK}/_delete_by_query" -XPOST -H "Content-Type: application/json" -d "{ \"query\": { \"match\": { \"$j\": \"$k\" } } }"
		done
	done
done
