#!/bin/zsh

rsync -a ./ root@crashreporting.postgresapp.com:/opt/crashreporting/

ssh root@crashreporting.postgresapp.com systemctl restart crashreporting.service

ssh root@crashreporting.postgresapp.com journalctl -u crashreporting -f