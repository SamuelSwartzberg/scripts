status=`nightlight status`
if [[ $status == on* ]] 
then
  nightlight off
else 
  nightlight on
fi
nightlight status

