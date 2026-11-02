FROM ghcr.io/home-assistant/base:3.24 AS builder

RUN apk add --no-cache build-base git autoconf automake libtool gettext-dev linux-headers libusb-dev openssl-dev zlib-dev pkgconf perl python3 bison flex

WORKDIR /build

RUN git clone --depth 1 --branch rtu_usb https://github.com/networkupstools/libmodbus.git

WORKDIR /build/libmodbus

RUN ./autogen.sh && ./configure --with-libusb --enable-static --disable-shared --prefix=/opt/modbus && make -j2 && make install

WORKDIR /build

RUN git clone --depth 1 --branch v2.8.5 https://github.com/networkupstools/nut.git

WORKDIR /build/nut

RUN ./autogen.sh && ./configure --prefix=/usr --sysconfdir=/etc/nut --with-drivers=apc_modbus,usbhid-ups --with-modbus+usb --with-modbus-includes="-I/opt/modbus/include/modbus" --with-modbus-libs="-L/opt/modbus/lib -lmodbus" --without-snmp --without-neon && make -j2 && make install

RUN echo "=== APC MODBUS DRIVER ===" && find /usr -name 'apc_modbus*' -type f

FROM ghcr.io/home-assistant/base:3.24

RUN apk add --no-cache libusb openssl zlib

COPY --from=builder /usr /usr 

COPY --from=builder /etc/nut /etc/nut

WORKDIR /

COPY run.sh /run.sh

RUN chmod 755 /run.sh

CMD ["/run.sh"]
