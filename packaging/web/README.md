# Web release instructions

## Javascript

1. Build an updated javascript release:
```
cd ~/devel/mapiah; rm -rf ~/devel/mapiah/build/web; flutter build web --release --base-href "/webapp/"
```

2. Create a compressed file with the new release:
```
cd ~/devel/mapiah/build/web; rm -f ../mapiah-web-release-javascript.tar.bz2; tar -cjvf ../mapiah-web-release-javascript.tar.bz2 *
```

3. Copy the compressed file to the hosting server (Hostinger) _webapp_ directory.
