#!/bin/sh

oc login -u user1

URL_FREELANCER="http://$(oc get route freelancer-s2i -n demo-s2i -o jsonpath='{.spec.host}')"
COUNT=0
COUNT_FIND_ALL=0
COUNT_FIND_ID=0
RAND_DIFF=1
STOP=false

while [ true ]; do
        COUNT=`expr $COUNT + 1`
	DIFF=`expr $COUNT_FIND_ALL - $COUNT_FIND_ID`
	#echo "Diff $DIFF, Random Diff $RAND_DIFF"

	if [ $DIFF == $RAND_DIFF ]
	then
		STOP=true
		#echo "STOPPED!!"
	elif [ $DIFF == 0 ]
	then
		STOP=false
		COUNT_FIND_ALL=0
		COUNT_FIND_ID=0
		RAND_DIFF=`expr $SECONDS % 10`
                RAND_DIFF=`expr $RAND_DIFF + 1`
		echo "RESET random diff $RAND_DIFF"
	fi

		
		
	if [ "$STOP" != true ]
	then
		STATUS=`curl -sL -w "%{http_code}" -I "${URL_FREELANCER}/freelancers" -o /dev/null`
                COUNT_FIND_ALL=`expr $COUNT_FIND_ALL + 1`
		echo "$COUNT_FIND_ALL - call /freelancers - $STATUS"
	fi
	



        	if (($SECONDS % 3 == 0))
        	then
            		STATUS=`curl -sL -w "%{http_code}" -I "${URL_FREELANCER}/freelancers/123456" -o /dev/null`
			COUNT_FIND_ID=`expr $COUNT_FIND_ID + 1`
			echo "$COUNT_FIND_ID - call /freelancers/123456 - $STATUS"
        	fi
	
	
        
        sleep `expr $SECONDS % 4`
done
