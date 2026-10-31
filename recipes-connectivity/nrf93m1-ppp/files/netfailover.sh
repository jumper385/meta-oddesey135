#!/bin/sh
# Ethernet first. If Ethernet has no internet, use LTE (ppp0).
PPP=ppp0
TARGETS="1.1.1.1 8.8.8.8"
FAIL_LIMIT=3        # failed checks before the change to LTE
OK_LIMIT=3          # good checks before the change back to Ethernet
INTERVAL=10         # seconds between checks
METRIC=5            # lower than the Ethernet route metric (10)
DNS_FILE=/run/nrf93m1.dns
ETH_RESOLV=/run/netfailover.resolv.eth

log() { logger -t netfailover "$*"; echo "$*"; }

ETH=""
# Find the interface of the Ethernet default route (not ppp0)
eth_dev() {
    ip route | awk '/^default via/ && $0 !~ /dev ppp/ {
        for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit } }'
}

eth_ok() {
    dev=$(eth_dev)
    [ -n "$dev" ] || return 1
    ETH=$dev
    for t in $TARGETS; do
        ping -I "$ETH" -c 1 -W 3 "$t" >/dev/null 2>&1 && return 0
    done
    return 1
}

resolved() { systemctl -q is-active systemd-resolved; }

dns_lte() {
    [ -s "$DNS_FILE" ] || return 0
    if resolved; then
        resolvectl dns "$PPP" $(cat "$DNS_FILE")
        resolvectl default-route "$PPP" yes
        resolvectl default-route "$ETH" no
    else
        [ -e "$ETH_RESOLV" ] || cp /etc/resolv.conf "$ETH_RESOLV"
        for d in $(cat "$DNS_FILE"); do echo "nameserver $d"; done > /etc/resolv.conf
    fi
}

dns_eth() {
    if resolved; then
        resolvectl default-route "$ETH" yes
        resolvectl revert "$PPP" 2>/dev/null
    elif [ -e "$ETH_RESOLV" ]; then
        cat "$ETH_RESOLV" > /etc/resolv.conf && rm -f "$ETH_RESOLV"
    fi
}

lte_active() { ip route | grep -q "^default dev $PPP .*metric $METRIC"; }

to_lte() {
    ip route replace default dev "$PPP" metric "$METRIC" 2>/dev/null || return 1
    dns_lte
}

to_eth() {
    ip route del default dev "$PPP" metric "$METRIC" 2>/dev/null
    dns_eth
}

state=eth; fails=0; oks=0
ip route del default dev "$PPP" metric "$METRIC" 2>/dev/null

while :; do
    if eth_ok; then oks=$((oks + 1)); fails=0
    else fails=$((fails + 1)); oks=0; fi

    if [ "$state" = eth ] && [ "$fails" -ge "$FAIL_LIMIT" ]; then
        if to_lte; then
            state=lte
            log "Ethernet has no internet. LTE is now the default route."
        fi
    elif [ "$state" = lte ]; then
        if [ "$oks" -ge "$OK_LIMIT" ]; then
            to_eth; state=eth
            log "Ethernet has internet. Ethernet is now the default route."
        elif ! lte_active; then
            to_lte && log "ppp0 connected again. LTE route added again."
        fi
    fi
    sleep "$INTERVAL"
done
