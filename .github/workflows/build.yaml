#!/usr/bin/with-contenv bashio
set -e

echo "Starting APC SMT750I Modbus USB (0.1.5)..."

export NUT_QUIET_INIT_UPSNOTIFY=true

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

echo "Starting apc_modbus driver (foreground)..."
/usr/bin/apc_modbus -a myups -u root -F &
sleep 3
if ! pgrep -x apc_modbus >/dev/null; then
  echo "Driver failed to start, exiting."
  exit 1
fi

echo "Starting NUT server..."
/usr/sbin/upsd -F &

# if driver or upsd dies, stop the add-on instead of serving stale data
wait -n
echo "A NUT process exited, stopping add-on."
exit 1
