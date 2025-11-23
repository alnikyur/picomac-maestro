#!/bin/bash
set -ex

PICOMAC="/opt/pico-mac"
PICOSDK="/opt/pico-sdk"

# --- 1. Build UMAC (VGA mode) ---------------------------------------
cd $PICOMAC/external/umac
make clean || true
make

# --- 2. Process ROM ---------------------------------------------------
if [ ! -f /rom.bin ]; then
    echo "ERROR: mount MacPlus ROM to /rom.bin"
    exit 1
fi

# copy ROM into project root
cp /rom.bin "$PICOMAC/rom_in.bin"

# run UMAC (ABSOLUTE PATHS!)
./main -r "$PICOMAC/rom_in.bin" -W "$PICOMAC/rom.bin" 2>/dev/null || true

# ensure ROM exists
if [ ! -f "$PICOMAC/rom.bin" ]; then
    echo "ERROR: UMAC did not generate rom.bin"
    exit 1
fi

# --- 3. DEMO disk -----------------------------------------------------
cd $PICOMAC

wget -q "http://retro.bluescsi.com/PicoMac-DemoDsk.zip"
unzip -o PicoMac-DemoDsk.zip

# --- 4. Generate incbin headers ---------------------------------------
rm -rf incbin
mkdir incbin

xxd -i < "$PICOMAC/rom.bin" > incbin/umac-rom.h
xxd -i < "$PICOMAC/DEMO.dsk" > incbin/umac-disc.h

# --- 5. Build Firmware -------------------------------------------------
rm -rf build
mkdir build
cd build

PICO_SDK_PATH=$PICOSDK cmake ..
make -j4

cp firmware.uf2 /work/firmware.uf2

echo "=== DONE ==="
