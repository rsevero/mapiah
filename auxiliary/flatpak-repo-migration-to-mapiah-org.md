# Migrating the Flatpak Repo from GitHub Pages to mapiah.org

## Background

Mapiah's self-hosted Flatpak repository is built by the GitHub Actions workflow
`.github/workflows/linux-flatter.yml` (using the [flatter](https://github.com/andyholmes/flatter)
action) and deployed to GitHub Pages. The app-id for this build is `org.mapiah.mapiah`.

Note: there is also a legacy Flathub build (`io.github.rsevero.mapiah`) that is no longer
maintained. The self-hosted repo is the current and future distribution channel.

The goal of this migration is to serve the Flatpak repository from a subdomain of `mapiah.org`
(e.g. `flatpak.mapiah.org`) instead of the default GitHub Pages URL
(`rsevero.github.io/mapiah`), giving Mapiah a permanent, project-controlled URL that is
independent of GitHub.

---

## Hosting strategy: GitHub Pages with custom domain

There is no need to self-host a web server. GitHub Pages supports custom domains natively.
The repository and its content remain on GitHub's infrastructure (free, reliable, CDN-backed);
only the URL changes.

The workflow already contains all the necessary logic:

- It detects when the target URL is not a `*.github.io` domain (line 68 of the workflow).
- It writes a `CNAME` file into the deployed Pages artifact (line 69), which tells GitHub Pages
  to serve the site under the custom domain.
- The generated `.flatpakref` file uses whatever URL is set in `DEFAULT_PAGES_URL`.

---

## GitHub Pages limits

GitHub Pages imposes the following soft limits (as of 2025):

| Resource | Limit | Type |
|---|---|---|
| Site size | 1 GB | Soft |
| Bandwidth | 100 GB / month | Soft |

"Soft" means GitHub will contact you before taking any action — there is no automatic hard block.

For a niche application like Mapiah:

- A full Flatpak install is roughly 50–150 MB (app bundle + OSTree delta against the
  freedesktop runtime).
- Incremental updates via OSTree static deltas are typically 5–30 MB.
- To hit the 100 GB/month bandwidth limit would require 700–2000 full installs per month,
  far beyond what a specialized cave-surveying tool realistically sees.
- Repo size grows with each release. Monitor the `gh-pages` branch size over time; pruning
  old OSTree objects may be needed after many releases.

**Conclusion:** GitHub Pages is a suitable host for the Mapiah Flatpak repo for the foreseeable
future.

---

## Changes required

### 1. DNS — add a CNAME record to mapiah.org

In the mapiah.org DNS configuration, add:

```
flatpak.mapiah.org.  CNAME  rsevero.github.io.
```

(Replace `rsevero` with the actual GitHub account owner if it ever changes.)

### 2. GitHub repository — enable custom domain in Pages settings

1. Go to the Mapiah GitHub repository → **Settings** → **Pages**.
2. Under **Custom domain**, enter `flatpak.mapiah.org` and click **Save**.
3. Enable **Enforce HTTPS** once the DNS record has propagated and GitHub has issued the
   TLS certificate (usually within a few minutes to an hour).

### 3. Workflow — change `DEFAULT_PAGES_URL`

In `.github/workflows/linux-flatter.yml`, change line 57 from:

```yaml
DEFAULT_PAGES_URL="https://${GITHUB_REPOSITORY_OWNER}.github.io/${GITHUB_REPOSITORY#*/}"
```

to:

```yaml
DEFAULT_PAGES_URL="https://flatpak.mapiah.org"
```

No other code changes are needed. The `CNAME` file generation and `.flatpakref` URL injection
are already driven by this variable.

---

## Deploying after the changes

Trigger a normal release (push a `vX.Y.Z` tag). The workflow will:

1. Build the Flatpak.
2. Generate `org.mapiah.mapiah.flatpakref` with `Url=https://flatpak.mapiah.org`.
3. Write `CNAME` containing `flatpak.mapiah.org` into the Pages artifact.
4. Deploy to GitHub Pages, which will then serve the content under `flatpak.mapiah.org`.

You can also trigger it manually via **Actions → Mapiah Linux Flatter → Run workflow**,
optionally overriding the `pages_url` input for testing.

---

## User migration

### What happens automatically

When GitHub Pages is configured with a custom domain, GitHub automatically issues a **301
redirect** from the old `rsevero.github.io/mapiah` URL to `flatpak.mapiah.org`. Flatpak and
OSTree may follow this redirect transparently for metadata fetches, so some existing users
might receive updates without any manual action.

However, redirect behavior is not guaranteed across all OSTree operations. Users should
explicitly update their remote.

### Recommended user action (one command)

Provide the following command prominently in release notes, the website, and the README for
the release that makes this change:

```bash
flatpak remote-modify --url=https://flatpak.mapiah.org mapiah
```

(Where `mapiah` is the name of the remote as it was added by the `.flatpakref`. Users can
check with `flatpak remotes`.)

### Staged migration plan

| Release | Action |
|---|---|
| Migration release | Deploy with new URL. Announce the change in release notes with the `flatpak remote-modify` command. GitHub Pages continues to redirect the old URL. |
| Next release | Assume most active users have updated. Optionally remove the old github.io redirect note from docs. |

### Users who installed via `.flatpakref` (re-install path)

If a user installs the new `.flatpakref` while the old remote is still present, Flatpak will
add the new remote URL alongside the old one (possibly under a different name). The user should
remove the old remote:

```bash
flatpak remotes          # identify the old remote name
flatpak remote-delete <old-remote-name>
```

---

## Verifying the migration

After the first deployment to the new domain:

```bash
# Confirm the repo is reachable
curl -I https://flatpak.mapiah.org/

# Confirm the .flatpakref is served and contains the correct URL
curl https://flatpak.mapiah.org/org.mapiah.mapiah.flatpakref

# Add the remote (fresh install test)
flatpak remote-add --if-not-exists mapiah https://flatpak.mapiah.org/

# Install (fresh install test)
flatpak install mapiah org.mapiah.mapiah
```

---

## References

- [flatter GitHub Action](https://github.com/andyholmes/flatter)
- [GitHub Pages custom domains documentation](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
- [GitHub Pages usage limits](https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages#usage-limits)
- [Flatpak documentation — hosting a repository](https://docs.flatpak.org/en/latest/hosting-a-repository.html)
