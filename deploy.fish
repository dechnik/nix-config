#!/usr/bin/env fish

set hosts $argv

if test -z "$hosts"
    echo "No hosts to deploy"
    exit 2
end

for host in $hosts
    nixos-rebuild --flake .\#$host switch --target-host $host --use-remote-sudo --use-substitutes
end
