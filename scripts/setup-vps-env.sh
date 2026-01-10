#!/usr/bin/env bash
# VPS Environment Setup Script
# Run this on your Hostinger VPS as root

set -e

echo "=== VPS Environment Setup ==="
echo ""

# Generate random passwords
generate_password() {
    openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32
}

# 1. GlitchTip Postgres
echo "[1/11] Creating /etc/glitchtip-postgres.env..."
GLITCHTIP_DB_PASS=$(generate_password)
cat > /etc/glitchtip-postgres.env << EOF
POSTGRES_USER=glitchtip
POSTGRES_PASSWORD=${GLITCHTIP_DB_PASS}
POSTGRES_DB=glitchtip
EOF
chmod 600 /etc/glitchtip-postgres.env

# 2. GlitchTip App
echo "[2/11] Creating /etc/glitchtip.env..."
GLITCHTIP_SECRET=$(generate_password)
cat > /etc/glitchtip.env << EOF
DATABASE_URL=postgres://glitchtip:${GLITCHTIP_DB_PASS}@glitchtip-postgres:5432/glitchtip
SECRET_KEY=${GLITCHTIP_SECRET}
REDIS_URL=redis://glitchtip-redis:6379/0
PORT=8000
GLITCHTIP_DOMAIN=https://glitchtip.msdqn.dev
DEFAULT_FROM_EMAIL=noreply@msdqn.dev
EMAIL_URL=smtp://mail.msdqn.dev:587
CELERY_WORKER_AUTOSCALE=1,3
CELERY_WORKER_MAX_TASKS_PER_CHILD=10000
EOF
chmod 600 /etc/glitchtip.env

# 3. Mailserver
echo "[3/11] Creating /etc/mailserver.env..."
cat > /etc/mailserver.env << EOF
OVERRIDE_HOSTNAME=mail.msdqn.dev
ENABLE_FAIL2BAN=1
ENABLE_SPAMASSASSIN=1
SPAMASSASSIN_SPAM_TO_INBOX=1
SSL_TYPE=manual
SSL_CERT_PATH=/tmp/ssl/fullchain.pem
SSL_KEY_PATH=/tmp/ssl/privkey.pem
ONE_DIR=1
ENABLE_POSTGREY=0
ENABLE_CLAMAV=0
ENABLE_AMAVIS=0
POSTMASTER_ADDRESS=postmaster@msdqn.dev
LOG_LEVEL=info
SUPERVISOR_LOGLEVEL=warn
EOF
chmod 600 /etc/mailserver.env

# 4. Roundcube DB
echo "[4/11] Creating /etc/roundcube-db.env..."
ROUNDCUBE_DB_PASS=$(generate_password)
cat > /etc/roundcube-db.env << EOF
POSTGRES_USER=roundcube
POSTGRES_PASSWORD=${ROUNDCUBE_DB_PASS}
POSTGRES_DB=roundcube
EOF
chmod 600 /etc/roundcube-db.env

# 5. Roundcube App
echo "[5/11] Creating /etc/roundcube.env..."
cat > /etc/roundcube.env << EOF
ROUNDCUBEMAIL_DB_TYPE=pgsql
ROUNDCUBEMAIL_DB_HOST=roundcube-db
ROUNDCUBEMAIL_DB_PORT=5432
ROUNDCUBEMAIL_DB_USER=roundcube
ROUNDCUBEMAIL_DB_PASSWORD=${ROUNDCUBE_DB_PASS}
ROUNDCUBEMAIL_DB_NAME=roundcube
EOF
chmod 600 /etc/roundcube.env

# 6. MinIO
echo "[6/11] Creating /etc/minio.env..."
MINIO_ROOT_PASS=$(generate_password)
cat > /etc/minio.env << EOF
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASS}
MINIO_BROWSER_REDIRECT_URL=https://minio.msdqn.dev
EOF
chmod 600 /etc/minio.env

# 7. n8n
echo "[7/11] Creating /etc/n8n.env..."
N8N_ENCRYPTION_KEY=$(generate_password)
cat > /etc/n8n.env << EOF
N8N_HOST=n8n.msdqn.dev
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://n8n.msdqn.dev/
N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
GENERIC_TIMEZONE=Asia/Jakarta
EOF
chmod 600 /etc/n8n.env

# 8. Personal Website
echo "[8/11] Creating /etc/personal-website.env..."
cat > /etc/personal-website.env << EOF
NODE_ENV=production
# Optional: Add SENTRY_DSN if you want error tracking
# SENTRY_DSN=https://xxx@glitchtip.msdqn.dev/1
EOF
chmod 600 /etc/personal-website.env

# 9. hpyd S3 config
echo "[9/11] Creating /var/lib/hpyd/s3.env..."
mkdir -p /var/lib/hpyd
cat > /var/lib/hpyd/s3.env << EOF
S3_ENDPOINT=https://s3.msdqn.dev
S3_ACCESS_KEY=admin
S3_SECRET_KEY=${MINIO_ROOT_PASS}
S3_BUCKET=hpyd
S3_REGION=us-east-1
EOF
chmod 600 /var/lib/hpyd/s3.env

# 10. RKM Backend
echo "[10/11] Creating /var/lib/rkm-backend/app.env..."
mkdir -p /var/lib/rkm-backend
RKM_JWT_SECRET=$(generate_password)
cat > /var/lib/rkm-backend/app.env << EOF
NODE_ENV=production
JWT_SECRET=${RKM_JWT_SECRET}
# Database is configured in Nix: postgresql://rkm:rkm@localhost:5432/rkm
EOF
chmod 600 /var/lib/rkm-backend/app.env

# 11. Netdata htpasswd
echo "[11/11] Creating /etc/nginx/htpasswd-netdata..."
mkdir -p /etc/nginx
NETDATA_PASS=$(generate_password)
# Using openssl for htpasswd generation (apache2-utils may not be installed)
echo "admin:$(openssl passwd -apr1 ${NETDATA_PASS})" > /etc/nginx/htpasswd-netdata
chmod 600 /etc/nginx/htpasswd-netdata

# Summary
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "SAVE THESE CREDENTIALS SOMEWHERE SAFE:"
echo "========================================"
echo ""
echo "GlitchTip:"
echo "  URL: https://glitchtip.msdqn.dev"
echo "  DB Password: ${GLITCHTIP_DB_PASS}"
echo ""
echo "MinIO:"
echo "  Console: https://minio.msdqn.dev"
echo "  S3 API: https://s3.msdqn.dev"
echo "  User: admin"
echo "  Password: ${MINIO_ROOT_PASS}"
echo ""
echo "n8n:"
echo "  URL: https://n8n.msdqn.dev"
echo "  Encryption Key: ${N8N_ENCRYPTION_KEY}"
echo ""
echo "Netdata:"
echo "  URL: https://netdata.msdqn.dev"
echo "  User: admin"
echo "  Password: ${NETDATA_PASS}"
echo ""
echo "RKM Backend:"
echo "  JWT Secret: ${RKM_JWT_SECRET}"
echo ""
echo "Roundcube Webmail:"
echo "  URL: https://webmail.msdqn.dev"
echo "  DB Password: ${ROUNDCUBE_DB_PASS}"
echo ""
echo "Mail Server:"
echo "  IMAP: mail.msdqn.dev:993 (SSL)"
echo "  SMTP: mail.msdqn.dev:465 (SSL)"
echo ""
echo "Next steps:"
echo "1. Create mail accounts: docker exec -it mailserver setup email add user@msdqn.dev"
echo "2. Generate DKIM key: docker exec -it mailserver setup config dkim"
echo "3. Create MinIO bucket 'hpyd' via console"
echo "4. Restart services: systemctl restart podman-*"
