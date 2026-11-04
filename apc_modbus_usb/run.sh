#!/usr/bin/with-contenv bashio
set -e

echo "Starting APC SMT750I Modbus USB (debug build 0.1.4)..."

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

cat > /etc/nut/upsd.users <<'EOF'
[admin]
  password = secret
  actions = set
  instcmds = all
EOF

echo "Checking USB devices..."
lsusb || true

echo "Starting apc_modbus driver in foreground with debug..."
/usr/bin/apc_modbus -a myups -u root -DDDDD -F 2>&1 &
DRV_PID=$!
sleep 4

if ! kill -0 "$DRV_PID" 2>/dev/null; then
  echo "!!! DRIVER EXITED EARLY !!!"
  wait "$DRV_PID" || echo "driver exit code: $?"
fi

# every 30 s print what upsd actually sees
( while true; do
    sleep 30
    echo "--- upsc myups ---"
    upsc myups@localhost 2>&1 | head -25
  done ) &

echo "Starting NUT server..."
exec /usr/sbin/upsd -F
