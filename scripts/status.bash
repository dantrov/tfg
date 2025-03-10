#!/bin/bash

check_service() {
    systemctl is-active --quiet "$1" && echo "online" || echo "offline"
}

check_docker_service() {
    docker ps --format "{{.Names}}" | grep -q "$1" && echo "online" || echo "offline"
}

echo "{"
echo "  \"Home Assistant\": \"$(check_docker_service home-assistant)\","
echo "  \"Open Media Vault\": \"$(check_service openmediavault)\","
echo "  \"OpenVPN\": \"$(check_service openvpn)\","
echo "  \"SQUID PROXY\": \"$(check_service squid)\","
echo "  \"PRIVOXY\": \"$(check_service privoxy)\","
echo "  \"DOCKER\": \"$(check_service docker)\""
echo "}"
