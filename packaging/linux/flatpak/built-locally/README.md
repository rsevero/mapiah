# Flatpak built locally instructions

1. Update Flutter version in _~/devel/mapiah/packaging/linux/flutter-build-docker-images/22.04/Dockerfile_

2. Update _flutter-build:22.04_ docker image:
```
cd ~/devel/mapiah/packaging/linux/flutter-build-docker-images/22.04; docker build -t rsev/flutter-build:22.04 .
```
3. Update _flatpak-build:22.04_ docker image:
```
cd ~/devel/mapiah/packaging/linux/flatpak-build-docker-images/22.04; docker build -t rsev/flatpak-build:22.04 .
```
4. Run flutter-build docker image:
```
docker run -i -t rsev/flatpak-build:22.04 bash
```
5. Create dirs:
```
sudo mkdir -p /app; sudo chown builder /app; sudo mkdir -p /devel/; sudo chown builder /devel; cd /devel;
```
6. Inside the running image, clone repos:
```
git clone --depth 1 https://github.com/rsevero/mapiah.git; git clone --depth 1 https://github.com/rsevero/mapiah_flathub_repo.git;
```
7. Build portable Linux release:
```
cd /devel/mapiah/; ./packaging/linux/build-flutter-app.sh
```
8. Update Mapiah-Linux-Portable.tar.gz sha256sum in /devel/mapiah_flathub_repo/build-flatpak.sh:
```
sed -i "s/sha256: .*/sha256: $(sha256sum Mapiah-Linux-Portable.tar.gz | awk '{print $1}')/" ../mapiah_flathub_repo/org.mapiah.Mapiah.yml
```
9. Build the flatpak
```
flatpak run org.flatpak.Builder --force-clean build-dir org.mapiah.Mapiah.yml --repo=repo
```
