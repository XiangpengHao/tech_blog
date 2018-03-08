#!/bin/bash
echo "begin deploying mainsite"
rsync -avzhe ssh ./public/ hao@vul.haoxp.xyz:/home/hao/tech_blog