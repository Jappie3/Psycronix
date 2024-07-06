#!/usr/bin/env bash

[ "$1" != "light" ] && [ "$1" != "dark" ] && exit 1

"$(rg ExecStart /run/current-system/etc/systemd/system/home-manager-jasper.service | cut -d ' ' -f 2)/specialisation/$1/activate"

