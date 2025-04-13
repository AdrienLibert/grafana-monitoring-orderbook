target: build

# Build all images
alias kustomize docker run --rm registry.k8s.io/kustomize/kustomize:v5.6.0

helm:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	curl -L -H "Accept: application/vnd.github.VERSION.raw" https://api.github.com/repos/AdrienLibert/orderbook/contents/chart.zip\?ref\=clean-repo-for-chart-only-purpose --output chart.zip
	unzip chart.zip -d .

clear_helm:
	helm repo remove flink-operator-repo
	helm repo remove prometheus-community

start_kafka:
	helm install bitnami bitnami/kafka --version 31.0.0 -n orderbook --create-namespace -f helm/kafka/values-local.yaml

stop_kafka:
	helm uninstall --ignore-not-found bitnami -n orderbook

build_deps: # TODO: change to main branch after orderbook repo is clean
	docker build https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:src/kafka_init -t local/kafka-init
	docker build https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:src/orderbook -t local/orderbook
	docker build https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:src/traderpool -t local/traderpool

build_kustomize:
	docker pull registry.k8s.io/kustomize/kustomize:v5.6.0

start_grafana: build_kustomize
	kustomize build src/grafana-dashboard | kubectl apply -n monitoring -f -
	helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f helm/grafana/values-local.yaml
	kubectl apply -f k8s/grafana -n monitoring

stop_grafana: build_kustomize
	kustomize build src/grafana-dashboard | kubectl delete -n monitoring -f -
	helm uninstall --ignore-not-found kube-prometheus-stack -n monitoring
	kubectl delete --ignore-not-found pvc kube-prometheus-stack-grafana -n monitoring
	kubectl delete --ignore-not-found svc kafka-exporter -n monitoring
	kubectl delete --ignore-not-found deployment kafka-exporter -n monitoring
	kubectl delete --ignore-not-found svc node-exporter -n monitoring
	kubectl delete --ignore-not-found service grafana-service -n monitoring

start_monitoring: start_kafka start_grafana
	helm install orderbook chart/ --namespace orderbook -f helm/orderbook/values-local.yaml

stop_monitoring: stop_kafka stop_grafana
	helm uninstall orderbook --ignore-not-found orderbook --namespace orderbook
