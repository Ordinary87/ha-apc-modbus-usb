
#!/usr/bin/with-contenv bashio
set -e

echo "Starting APC Modbus USB NUT..."

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
EOF

cat > /etc/nut/upsd.conf <<'EOF'
LISTEN 0.0.0.0 3493
EOF

echo "Starting APC Modbus driver..."
/usr/sbin/upsdrvctl start

echo "Starting NUT server..."
exec /usr/sbin/upsd -F
