# Important information:
***This project is created only for education process and can not be used for 
law violation or personal gain. The author of this project is not responsible for any possible harm caused by the materials of this project.***

# Важная информация:
***Данный проект создан исключительно в образовательных целях, и не может быть использован в целях нарушающих законодательство, в корыстных целях или для получения какой-либо выгоды как для самого автора так и лиц его использующих.
Автор данного проекта не несет ответственности за любой возможный вред, причиненный материалами данного проекта.***

# WPA2-Enterprise-Automatron
WPA2 Enterprise hack automatization script

```
root@kali:/git/WPA2-Enterprise-Automatron# ./automatron.sh -h
Usage: ./automatron.sh [-h] [-m MDK3_IFACE] [-w HOSTAPD_WPE_IFACE] [-e ESSID]
               [-c HOSTAPD_CONF] [-l LOG_DIR] [-d DEAUTH_CHANNELS]
               [-s] [-k] [-K] [-C]

WPA2 Enterprise hack automatization script

Optional arguments:
  -h, --help            show this help message and exit
  -m MDK3_IFACE, --mdk3-iface MDK3_IFACE
                        Set wireless interface for send deauth packets
                        (default: wlan1)
  -w HOSTAPD_WPE_IFACE, --hostapd-wpe-iface HOSTAPD_WPE_IFACE
                        Set wireless interface for hostapd-wpe
                        (default: wlan2)
  -e ESSID, --essid ESSID
                        Set ESSID for WPA2 Enterprise AP (default: test)
  -c HOSTAPD_CONF, --hostapd-conf HOSTAPD_CONF
                        Set path to conf file for hostapd-wpe
                        (default: /etc/hostapd-wpe/hostapd-wpe.conf)
  -l LOG_DIR, --log-dir LOG_DIR
                        Set path to directory with logs (default: /var/log)
  -d DEAUTH_CHANNELS, --deauth-channels DEAUTH_CHANNELS
                        Set channels for deauth channels
                        (default: 1,2,3,4,5,6,7,8,9,10,11,12)
  -s, --start           Start mdk3 and hostapd-wpe process
  -k, --karma           Set Karma mode for hostapd-wpe
  -K, --kill            Kill mdk3 and hostapd-wpe process
  -C, --check           Check mdk3 and hostapd-wpe process
  -N, --netntlm         Print unique users with NETNTLM hashes
  -H, --netntlm-hashcat Print unique users with NETNTLM hashes (hashcat format)
  -D, --delete-log      Delete log files
  ```
