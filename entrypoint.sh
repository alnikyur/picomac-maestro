#!/bin/bash
set -ex

PICOMAC="/opt/pico-mac"
PICOSDK="/opt/pico-sdk"

if [ ! -f /rom.bin ]; then
    echo "ERROR: mount ROM.bin into /rom.bin"
    exit 1
fi

echo "=== 1. Build UMAC ==="
cd $PICOMAC/external/umac
make clean || true
make MEMSIZE=208 DISP_WIDTH=640 DISP_HEIGHT=480

echo "=== 2. Convert ROM ==="
cp /rom.bin /work/rom.bin
./main -r /work/rom.bin -W /work/rom_patched.bin 2>/dev/null || true
cp /work/rom_patched.bin $PICOMAC/rom.bin

echo "=== 3. Prepare incbin ==="
cd $PICOMAC
rm -rf incbin
mkdir incbin

if [ ! -f /work/DEMO.dsk ]; then
    echo "=== Downloading DEMO.dsk ==="
    wget -q "http://retro.bluescsi.com/PicoMac-DemoDsk.zip" -O /tmp/demo.zip
    unzip -o /tmp/demo.zip -d /tmp/
    cp /tmp/DEMO.dsk /work/DEMO.dsk
fi


xxd -i < rom.bin > incbin/umac-rom.h
xxd -i < /work/DEMO.dsk > incbin/umac-disc.h

echo "=== 4. Build firmware (FULL VGA) ==="
rm -rf build
mkdir build
cd build

PICO_SDK_PATH=$PICOSDK cmake ..

make -j$(nproc)

cp firmware.uf2 /work/firmware.uf2

echo "=== DONE ==="
echo "Firmware saved to /work/firmware.uf2"
