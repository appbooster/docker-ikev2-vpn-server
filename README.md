# IKEv2 VPN Server on Docker, with Let's Encrypt Certificates

## Usage
### Start the IKEv2 VPN Server
Set VPNHOST (vpn domain, example: vpn1.example.com), LEEMAIL (email, for Let's Encrypt Certificates).

Run vpn server:
    
    docker-compose up -d

### Add user

    docker exec -it ikev2-server ./adduser TestUser
    
### Remove user
    
    docker exec -it ikev2-server ./rmuser TestUser
