
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
EOF

cat > /etc/nut/upsd.conf <<'EOF'
LISTEN 0.0.0.0 3493
EOF

echo "Checking APC Modbus driver options..."
/usr/libexec/nut/apc_modbus -h || true

echo "Checking USB devices..."
ls -l /dev/bus/usb/*/* || true

echo "Starting APC Modbus USB driver..."
/usr/sbin/upsdrvctl -D start

echo "Starting NUT server..."
exec /usr/sbin/upsd -F
