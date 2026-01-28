#!/bin/sh

# sudo apt-get update -y
# sudo apt-get install nginx -y
# sudo systemctl start nginx
# sudo systemctl enable nginx
cat > index.html <<'EOF'
${index_html}
EOF

nohup busybox httpd -f -p 8080 &