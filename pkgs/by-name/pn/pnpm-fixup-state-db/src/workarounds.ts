import { lt } from 'semver'
import type { Metadata } from './index.js'

// pnpm 12.15 introduced pinning packages using other hashes? This
// breaks reproducibility across versions, so let's drop it for
// now. See
// https://github.com/pnpm/pnpm/commit/7b0d6873a68ff10862e1f0fa03c728af4bc7b56a
// At the time of writing, fetcherVersion 6 doesn't exist yet
// This is just in preparation it as we don't want to do this forever
export function applyTarIntegrityWorkaround(
  fetcherVersion: number,
  pnpmVersion: string,
  data: Metadata,
) {
  if (fetcherVersion >= 6) {
    // Do not apply workaround for future fetcher versions
    return
  }
  if (lt(pnpmVersion, '12.15.0')) {
    // This field shouldn't have existed in prior versions but let's be safe and not touch older FODs
    return
  }
  if (!('tarIntegrity' in data)) {
    return
  }
  delete data['tarIntegrity']
}

// pnpm v11 stored the manifest field for every dependency, including Git
// packages. pnpm 12.0.0 stopped doing this (probably a regression). This
// was fixed in 12.15.0. This means that technically v11 FODs and v12.15.0+
// FODs should be compatible, while everything in between is tainted.
// So now we need to keep doing it incorrectly by reintroducing the
// regression after the fact. We do that by deleting the `manifest` field
// for Git packages
// Again, we will drop this with an upcoming fetcherVersion 6
export function applyGitManifestWorkaround(
  fetcherVersion: number,
  pnpmVersion: string,
  data: Metadata,
) {
  if (fetcherVersion >= 6) {
    // Do not apply workaround for future fetcher versions
    return
  }
  if (lt(pnpmVersion, '12.15.0')) {
    // Do not apply workaround for pnpm versions that include the regression
    // or didn't have to fix it in the first place (i.e. pnpm v11)
    return
  }
  if (!('requiresPrepare' in data)) {
    // `requiresPrepare` seems to be the best indicator for a Git dependency
    // If it's not set, we are not looking at a Git dependency it seems?
    return
  }
  if (!('manifest' in data)) {
    return
  }
  delete data['manifest']
}
