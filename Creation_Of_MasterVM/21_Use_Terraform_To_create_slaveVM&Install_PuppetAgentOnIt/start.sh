terraform init
while true
do
sleep 10
x=$(terraform apply -auto-approve | grep "Apply complete!")
if [ "$x" != "" ]
then
exit
break
else
break
fi
done
