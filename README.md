# IKEv2 VPN Server on Docker, with Let's Encrypt Certificates

## Usage
### Build container

    ./build.sh

### Start the IKEv2 VPN Server
Update .env file

VPNHOST (vpn domain, example: vpn1.example.com)

LEEMAIL (email, for Let's Encrypt Certificates)

SPEED_LIMIT (speed limit per user, example 2) if you want add limit bandwidth for users

DNS_SERVERS (yours DNS servers)

RADIUS_SERVER (your radius server address)

RADIUS_SERVER_SECRET (secret key for radius server)

REMOTE_SERVER your server url (https://www.example.com) to which data will be sent

Run vpn server:

    ./start.sh

Run vpn server with docker-compose:

    docker-compose up -d

### Add user

    docker exec -it ikev2-vpn-server ./adduser.sh TestUser
    
### Remove user
    
    docker exec -it ikev2-vpn-server ./rmuser.sh TestUser
