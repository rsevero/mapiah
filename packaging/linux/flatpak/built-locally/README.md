# Flatpak built locally instructions

1. Update Flutter version in _~/devel/mapiah/packaging/linux/flutter-build/22.04/Dockerfile_
   
2. Update _flutter-build:22.04_ docker image:
```
cd ~/devel/mapiah/packaging/linux/flutter-build/22.04; docker build -t rsev/flutter-build:22.04 .
```

3. Run flutter-build docker image:
```
docker run -i -t rsev/flutter-build:22.04 bash
```

4. Create dirs:
```
sudo mkdir -p /app; sudo chown builder /app; sudo mkdir -p /devel/; sudo chown builder /devel; cd /devel;
```

5. Inside the running image, clone mapiah repo:
```
git clone https://github.com/rsevero/mapiah.git;
```

6. Clone mapiah_flathub_repo repo:
```
git clone https://github.com/rsevero/mapiah_flathub_repo.git;
```

