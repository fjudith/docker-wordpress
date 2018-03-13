
kubectl delete -f https://raw.githubusercontent.com/fjudith/docker-wordpress/master/kubernetes/local-volumes.yaml
kubectl delete secret wp-mysql-pass
kubectl delete -f https://raw.githubusercontent.com/fjudith/docker-wordpress/master/kubernetes/mysql-deployment.yaml
kubectl delete -f https://raw.githubusercontent.com/fjudith/docker-wordpress/master/kubernetes/wordpress-deployment.yaml