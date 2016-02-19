#!/bin/sh

[[ -z "$1" ]] && echo "Pass a hostname argument." && exit 0

format="
            time_namelookup:  %{time_namelookup}
               time_connect:  %{time_connect}
            time_appconnect:  %{time_appconnect}
           time_pretransfer:  %{time_pretransfer}
              time_redirect:  %{time_redirect}
         time_starttransfer:  %{time_starttransfer}
                            ----------
                 time_total:  %{time_total}\n\n"

curl -w "$format" -o /dev/null -s $1
