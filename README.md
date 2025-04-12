# OrderBook Monitoring with Grafana

Monitor an orderbook data generator using Grafana, built from the repository: [AdrienLibert/orderbook](https://github.com/AdrienLibert/orderbook).  

Developed in collaboration with [@ShikoteiCoding](https://github.com/ShikoteiCoding).

## Installation

### Dependencies

Install the required dependencies with the following commands:

```
make helm
make build_deps
```

### Start Monitoring

Launch the monitoring service:

```
make start_monitoring
```

Access the Grafana dashboard at:  
[http://localhost:30300/](http://localhost:30300/)

**Credentials:**
- Username: `admin`
- Password: `admin`

### Stop Monitoring

Stop the monitoring service:

```
make stop_monitoring
```