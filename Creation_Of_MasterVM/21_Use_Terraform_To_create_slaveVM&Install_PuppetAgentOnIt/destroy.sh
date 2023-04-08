while true
do
terraform destroy -auto-approve
if [ $? -eq 0 ]
then
exit
fi
sleep 10
done
