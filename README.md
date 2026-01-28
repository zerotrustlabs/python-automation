# python-automation

Task

Create a python script that can loop through flile and filter the for only json fies
create a function as a file watcher. to check for modified time
use the function to loop every 5 second to return changes in a file
If the changes to the file extension then trigger a docker build operation.
In the docker build create a template to change the settings
If build is successful trigger a terraform solution to deploy an infrastructure in ec2 and use cloudinit to deploy the docker file
Ensure the main ec2 instance is in private subnet and a bastiono public subnet
Complete assesment and terraform associate course


dlete all

docker rm $(docker ps -aq) && docker rmi $(docker images -aq)
alias delete-all="docker rm $(docker ps -aq) && docker rmi $(docker images -aq)"