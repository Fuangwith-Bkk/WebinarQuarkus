#!/bin/sh

oc login -u user1

URL_FREELANCER="http://$(oc get route freelancer-s2i -n demo-s2i -o jsonpath='{.spec.host}')"
COUNT=0

while [ true ]; do
        COUNT=`expr $COUNT + 1`
	STATUS=`curl -sL -w "%{http_code}" -I "${URL_FREELANCER}/freelancers" -o /dev/null`
        echo "$COUNT - call /freelancers - $STATUS"

        if (($SECONDS % 3 == 0))
        then
            	STATUS=`curl -sL -w "%{http_code}" -I "${URL_FREELANCER}/freelancers/123456" -o /dev/null`
		echo "      - call /freelancers/123456 - $STATUS"
        fi
        
        sleep `expr $SECONDS % 4`
done
