# anyconnectVPNswitcher
This is a set of batch scripts and setup to kind of automate the connection to VPN using "Cisco AnyConnect Secure Mobility Agent".  The main script is ```anyconnectVPNswitcher.bat```.

It accepts as parameter the name of one of the configured hosts. To list the hosts, do:
``` C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client>vpncli.exe hosts
Cisco AnyConnect Secure Mobility Client (version 4.3.05017) .

Copyright (c) 2004 - 2016 Cisco Systems, Inc.  All Rights Reserved.

[hosts]:

> VPNServer1
> VPNServer2
> VPNServer3

C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client>
``` 

Additionally, it restarts the "Cisco AnyConnect Secure Mobility Agent" service. This is because, at least on my machine, sometimes it messes up the routing, and I loose the internet after connecting to VPN.

# usage

1. Ensure the path to the script is present in the Environment Variables for your user.
2. to connect to a profile:
   ```
    anyconnectVPNswitcher.bat VPNServer1
   ```
3. to disconnect:
   ```
    anyconnectVPNswitcher.bat disconnect
   ```
But, because the service restart requires elevated permissions, better create shortcuts with Administrator privileges for every parameter. Meaning you can have shortcuts like so:
- ```VPNServer1.bat.lnk```
- ```VPNServer2.bat.lnk```
- ```VPNServer3.bat.lnk```
- ```disconnectVPN.bat.lnk```

And then just call them via ```Run```, or have them on your desktop if you like


# WARNING
This approach will expose you user/password in clear.