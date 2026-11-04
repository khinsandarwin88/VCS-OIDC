#!/bin/bash
# Script to deploy a very simple web application.
# The web app has a customizable image and some text.

cat << EOM > /var/www/html/index.html
<html>
  <head><title>AWS VPC Peering</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">

  <!-- BEGIN -->
  <center><img src="http://${PLACEHOLDER}/${WIDTH}/${HEIGHT}?id=${PLACEHOLDER_ID}"></img></center>
  <center><h2>AWS VPC Peering — VCS-driven on HCP Terraform</h2></center>
  Welcome to ${PREFIX}'s app..

  <!-- END -->

  </div>
  </body>
</html>
EOM

echo "Script complete."
