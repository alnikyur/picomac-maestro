# PicoMac builder how to

Build docker image:
```
docker build -t picomac-builder .
```

Then run the builder with your Mac Plus ROM file:
```
docker run --rm \
  -v $(pwd):/work \
  -v $(pwd)/ROM/MacPlus.ROM:/rom.bin \
  picomac-builder
```
