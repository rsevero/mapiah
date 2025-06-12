# Web version release instructions

1. Build an updated web version:
```
flutter build web --release --base-href "/webapp/"
```

2. Create a compressed file with the new release:
```
cd ~/devel/mapiah/build/web; tar -czvf mapiah-web-release.tar.gz *
```

3. Copy the compressed file to the hosting server (Hostinger).

