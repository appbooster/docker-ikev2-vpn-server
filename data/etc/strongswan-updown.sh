#! /bin/sh
case "$PLUTO_VERB:$1" in
up-client:)
  now=$(date +"%T")
  echo "action: up, ${PLUTO_XAUTH_ID}: ${PLUTO_PEER} at $now"
  ;;
down-client:)
  now=$(date +"%T")
  echo "action: down, ${PLUTO_XAUTH_ID}: ${PLUTO_PEER} at $now"
  ;;
esac