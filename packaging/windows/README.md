# Windows release instructions
On Windows:

1. Update mapiah repository:
```
git pull
```

2. Update app version at:
   1. pubspec.yaml
   2. packaging/linux/org.mapiah.Mapiah.metainfo.xml

3. Build upgraded windows release:
```
flutter build windows
```

