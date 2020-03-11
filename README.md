# IKEv2 VPN Server on Docker, with Let's Encrypt Certificates

## Usage
### Start the IKEv2 VPN Server
Set VPNHOST (vpn domain, example: vpn1.example.com), LEEMAIL (email, for Let's Encrypt Certificates) at .env file.

Run vpn server:

    ./start.sh

Run vpn server with docker-compose:

    docker-compose up -d

### Add user

    docker exec -it ikev2-vpn-server ./adduser TestUser
    
### Remove user
    
    docker exec -it ikev2-vpn-server ./rmuser TestUser
