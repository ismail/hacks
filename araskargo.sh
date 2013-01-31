#!/usr/bin/env zsh

vars=(`echo $1|tr "/" " "`)

seri=$vars[1]
irs=$vars[2]
ref=$vars[3]

curl -s "http://www.araskargo.com.tr/web_18712_1/function_results.aspx?query=1&querydetail=1&seri_no=$seri&irs_no=$irs&ref_no=$ref"| grep LabelQueryAnswer1|\
     perl -i -pe "s,<.*?>, ,g;" -pe "s,\s+, ,g;" -pe "s,&nbsp;,,g;" -pe "s/.//;" -pe "s,\. ,\.\n,g"

