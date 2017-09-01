#!/bin/sh

#I really need some type of process management
#for running two programs in the same docker container

CLIENT_CERT_PATH=/etc/stunnel/client.pem
inject_client_cert() {
  cat /run/secrets/*cert* > "$CLIENT_CERT_PATH"
  #check to make sure it got something
  if [ $? -eq 0 ]; then
    echo 'imported certificate from docker secret'
  else
    echo 'could not import certificate from docker secret, exiting'
    exit 1
  fi
}

generate_server_cert() {
  KEY_CERT_FILE=/etc/stunnel/server.pem
  CERT_ONLY_FILE=/etc/stunnel/server_cert_only.pem
  #feed in the required parameters to cert generation, spaces in heredoc are important
  /usr/bin/openssl req -utf8 -newkey rsa:2048 -keyout $KEY_CERT_FILE -nodes -x509 -days 3650 -out $CERT_ONLY_FILE << EOF
US
Arizona
TunnelTown
Miners, Inc.



EOF
  echo >> $KEY_CERT_FILE
  cat $CERT_ONLY_FILE >> $KEY_CERT_FILE
}

#cert setup
if [ -f "$CLIENT_CERT_PATH" ]; then
  echo 'someone already mounted a cert via docker volume'
else
  echo 'injecting client certificate from docker secret'
  inject_client_cert
fi

echo 'generating server certificates'
generate_server_cert

#start squid and go to background
squid

#start stunnel
stunnel /etc/stunnel/stunnel.conf
