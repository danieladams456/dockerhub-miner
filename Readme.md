## Miner
Uses stunnel and squid to allow you to securely pop HTTP[s] out of a tunnel wherever you run this container.

It exposes the stunnel proxy listener as port 8080.

#### Stunnel client configuration
```
client = yes
cert = /home/$USER/.stunnel/stunnel.pem

;performance optimization to match server side
socket = r:TCP_NODELAY=1

[squid]
accept = 127.0.0.1:3128
connect = $REMOTE_IP:8080
```

#### Docker-compose for Docker secret
(any secret with "cert" in the name will do.)
```yaml
version: '3.1'

services:
  miner:
    image: danieladams456/miner
    ports:
      - "8080:8080"
    deploy:
      replicas: 1
      restart_policy:
        max_attempts: 3
        window: 3m
    secrets:
      - test_cert

secrets:
  test_cert:
    external: true
```
