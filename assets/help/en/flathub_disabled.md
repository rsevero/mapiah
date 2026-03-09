# Update available

Newer versions of Mapiah are available, but this Flathub build is not upgraded anymore.

Update instrcutions (on the terminal):

```
# Remove this version of Mapiah.
flatpak remove io.github.rsevero.mapiah
# Install the latest Flatpak version of Mapiah from Github.
flatpak install --user --from https://rsevero.github.io/mapiah/org.mapiah.mapiah.flatpakref
```

If you want, you can also check more info on the Mapiah page on Flathub: [Mapiah on Flathub](https://flathub.org/apps/details/io.github.rsevero.mapiah)

## Rationale
The Mapiah Flathub build is no longer maintained due to the following factors:

- The build process is excessively slow, resource-intensive, and involves multiple manual steps;
- Flathub's restrictions on external applications require Mapiah to bundle Therion and its dependencies, increasing the package size from roughly 14MB to over 950MB;
- Bundled Therion is significantly slower than the native one. 
