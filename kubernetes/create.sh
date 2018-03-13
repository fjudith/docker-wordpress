tr --delete '\n' <password.txt >.strippedpassword.txt && mv .strippedpassword.txt password.txt
kubectl create -f https://raw.githubusercontent.com/fjudith/docker-wordpress/master/kubernetes/local-volumes.yaml
kubectl create secret generic wp-mysql-pass --from-file=password.txt
kubectl create -f https://raw.githubusercontent.com/fjudith/docker-wordpress/master/kubernetes/mysql-deployment.yaml
kubectl create -f https://raw.githubusercontent.com/fjudith/docker-wordpress/master/kubernetes/wordpress-deployment.yaml