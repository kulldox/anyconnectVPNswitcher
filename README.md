# anyconnectVPNswitcher
This is a set of batch scripts and setup to kind of automate the connection to VPN using "Cisco AnyConnect Secure Mobility Agent".  The main script is ```anyconnectVPNswitcher.bat```  It accepts as parameter the name of one of the configured hosts. To list the hosts, do: ``` C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client>vpncli.exe hosts Cisco AnyConnect Secure Mobility Client (version 4.3.05017) .  Copyright (c) 2004 - 2016 Cisco Systems, Inc.  All Rights Reserved.       [hosts]:      > VPNServer1     > VPNServer2     > VPNServer3     C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client> ```  Additionally, it restarts the "Cisco AnyConnect Secure Mobility Agent" service. This is because, at least on my machine, sometimes it messes up the routing, and I loose the internet after connecting to VPN.