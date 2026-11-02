#!/usr/bin/with-contenv bashio
set -e

echo "Starting APC SMT750I Modbus USB..."

mkdir -p /var/state/ups /run/nut
chmod 755 /var/state/ups

cat > /etc/nut/ups.conf <<'EOF'
[myups]
  driver = apc_modbus
  port = auto
  porttype = usb
  vendorid = 051d
  productid = 0003
  pollinterval = 2
  maxretry = 3
EOF

cat > /etc/nut/upsd.conf <<'EOF'
LISTEN 0.0.0.0 3493
EOF

echo "Checking USB devices..."
lsusb || true

echo "Starting NUT drivers..."
/usr/sbin/upsdrvctl -u root -D start || true

echo "Starting NUT server..."
exec /usr/sbin/upsd -F
