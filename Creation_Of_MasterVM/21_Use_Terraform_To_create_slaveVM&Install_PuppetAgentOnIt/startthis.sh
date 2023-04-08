terraform init
sleep 10
while true
do
terraform apply -auto-approve
if [ $? -eq 0 ]
then
exit
fi
done

