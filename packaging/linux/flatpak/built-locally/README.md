# Flatpak built locally instructions

1. Update Flutter version in _~/devel/mapiah/packaging/linux/flutter-build-docker-images/22.04/Dockerfile_
   
2. Update _flutter-build:22.04_ docker image:
```
cd ~/devel/mapiah/packaging/linux/flutter-build-docker-images/22.04; docker build -t rsev/flutter-build:22.04 .
```

3. Run flutter-build docker image:
```
docker run -i -t rsev/flutter-build:22.04 bash
```

4. Create dirs:
```
sudo mkdir -p /app; sudo chown builder /app; sudo mkdir -p /devel/; sudo chown builder /devel; cd /devel;
```

5. Inside the running image, clone repos:
```
git clone https://github.com/rsevero/mapiah.git; git clone https://github.com/rsevero/mapiah_flathub_repo.git;
```

6. Build portable Linux release:
```
cd /devel/mapiah/packaging/linux; ./build-flutter-app.sh
```

