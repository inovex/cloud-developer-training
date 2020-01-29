aws logs describe-log-groups --profile inovex-cdt --query 'logGroups[*].logGroupName' --output table | \
awk '{print $2}' | grep -v ^$ | while read x; do  echo "deleting $x" ; aws logs delete-log-group --profile inovex-cdt --log-group-name $x; done
