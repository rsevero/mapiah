<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion symbol-set showcases

This directory contains one `.th2` drawing and one `.thconfig` export for each
Therion symbol set:

- ASF
- AUT
- BCRA
- NSS
- NZSS
- SBE
- SKBB
- SM
- UIS

All configurations source the shared `therion_showcase.th` survey. Run Therion
from this directory, passing the configuration for the symbol set to inspect:

```sh
therion therion_uis_showcase.thconfig
```

Generated PDFs are ignored by Git. The SM configuration demonstrates its
special grid and scale-bar symbols through layout directives. SKBB's
`dimensions` area symbol is generated from survey dimensions rather than an
ordinary TH2 area, so it is not represented as an area block in its fixture.
