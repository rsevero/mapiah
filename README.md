# Mapiah

[Free software](https://www.gnu.org/philosophy/free-sw.en.html) graphical interface for [Therion](https://therion.speleo.sk/) cave mapping written in [Flutter](https://flutter.dev/).

## Main objectives
User-friendly interface to the powerful Therion mapping software.

As an intended side effect, it aims to completely replace xTherion, the venerable but ostensibly ancient Therion graphical interface.

Also create a thriving community of users and developers to make it as powerful and user friendly as such community needs and creates.

## Interesting characteristics
* Visually distinguish all point, line, and area types supported by Therion.
* Graphical interface for editing all supported options of points, lines, and areas supported by Therion.
* Multiple mouse and keyboard pan and zoom options.
* On save, original file lines are only changed if an actual edit modified them, which facilitates version control management.
* Uses Therion as the source of truth regarding supported features; i.e., if Therion supports it, Mapiah should support it as well.
  * As a secondary effect, tries to update and detail the Therion Book so it better reflects Therion features.
* Equivalent versions for Linux, MacOS and Windows.
* Unlimited undo/redo.
* Redos available after some undos and new actions merged in the undo queue.

## Current status
With the release of version 0.3.0, Mapiah is considered to have reached "real editing" full capabilities.

Mapiah is in fast development stage, but it is already usable for real mapping work. It is being used by the author and some other people to map real caves, and it is already being used in some caving courses.

If you have TH2 files you want to edit and want to give Mapiah a try, please do. If you find any issue, please report it as a [Mapiah Issue](https://github.com/rsevero/mapiah/issues).

Linux AppImage and Flatpak/Flathub and Windows versions are being used regularly. MacOS version lacks a developer with MacOS to properly test it.

## Installation

### Linux

#### AppImage
Available at [Mapiah releases](https://github.com/rsevero/mapiah/releases).

#### Flatpak
Mapiah Flatpak version moved back to Flathub.

If you have previously installed a Flatpak package directly downloaded from [Mapiah releases](https://github.com/rsevero/mapiah/releases), please uninstall it and install the Flathub version instead. You will need Flathub installed in your system first: [Flathub setup instructions](https://flatpak.org/setup/).

```bash
flatpak remove org.mapiah.mapiah
flatpak install io.github.rsevero.mapiah
```

If you have already installed the Flathub version, you can update it with:

```bash
flatpak update io.github.rsevero.mapiah
```

##### Install from Mapiah GitHub Pages Flatpak repo
You can install using the `.flatpakref` link below:
`https://rsevero.github.io/mapiah/org.mapiah.mapiah.flatpakref`

If that URL returns `404`, wait a few minutes and try again. New releases can take a short time to appear on GitHub Pages.

```bash
# Option 1: install directly from the generated flatpakref
flatpak install --user --from https://rsevero.github.io/mapiah/org.mapiah.mapiah.flatpakref

# Option 2: add the generated repository and install from it
flatpak remote-add --if-not-exists mapiah https://rsevero.github.io/mapiah/index.flatpakrepo
flatpak install --user mapiah org.mapiah.mapiah
```

#### Other formats
If someone is interested in creating Linux packages in other formats like arch, deb, rpm, snap or other package and is interested in my help, please contact me at rsev AT pm.me.

### MacOS
Available at [Mapiah releases](https://github.com/rsevero/mapiah/releases).

As Mapiah has no Apple compatible signing yet its necessary to allow special permission to run Mapiah in MacOS: [Open Any Way](https://support.apple.com/en-us/102445#openanyway)

### Windows
Available at [Mapiah releases](https://github.com/rsevero/mapiah/releases).

Apparently Microsoft Defender is keen on flagging unknown executables as having some kind of malware. Sometimes as [Bearfoos.A!ml](https://answers.microsoft.com/en-us/windows/forum/all/bearfoosaml-false-alarm/37707c6a-8222-44ad-a604-d75918dfb519), sometimes as [Trojan:Win32/Wacatac.B!ml](https://github.com/flutter/flutter/issues/118430). Maybe others.

If you want to be extra sure, you can check Mapiah's setup exe file with some online virus scanner service before installing it.

## Reporting bugs

As is probably the case in all Free Software projects, the developers of Mapiah aim to produce completely bug-free software. As it happens in all software, they fail.

Please register bugs and enhancement suggestions as a [Mapiah Issue](https://github.com/rsevero/mapiah/issues).

When reporting bugs, please consider the following advice, which tries to make everybody happier:

* Check if the behavior you are identifying as a bug is actually a bug. For applicable types of issues, remember that Mapiah treats Therion as the 'source of truth.'
* If applicable, check if the Therion Book clearly defines the behavior you are expecting. If not, please consider submitting an update for the Therion Book.
* Remember that it is almost impossible for a developer to fix an issue the developer can't reproduce or at least see. To help with that, you can (should?):
  * Provide detailed steps explaining how to reproduce the bug;
  * Provide minimal files necessary to reproduce the bug;
  * Provide videos showing the bug (especially recommended for interaction-related issues);
  * Any other info that might help the developers visualize the issue you are reporting.

If you have some free time and want to see the above recommendations more extensively described, read [How to Report Bugs Effectively](https://www.chiark.greenend.org.uk/~sgtatham/bugs.html). I read it a few decades ago and am still impacted.

## Changelog and Roadmap

[Changelog](https://github.com/rsevero/mapiah/blob/main/CHANGELOG.md)

[Roadmap](https://github.com/rsevero/mapiah/blob/main/ROADMAP.md)

## Name origin

_Mapiah_ comes from the (Brazilian) Portuguese word _mapear_.

In Portuguese, _Let's go mapping?_ is _Vamos mapear?_

In Brazil, it is usually pronounced as _Vâmu mapiá?_

As the internet doesn't deal well with accents, _mapiá_ became _mapiah_.

## Meta

Rodrigo Severo – rsev AT pm.me

Distributed under the GNU GPL 3 license. See [LICENSE](https://github.com/rsevero/mapiah/blob/main/LICENSE.md) for more information.

[https://github.com/rsevero/mapiah](https://github.com/rsevero/mapiah)

## Contributing

1. Fork it (<https://github.com/rsevero/mapiah/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
