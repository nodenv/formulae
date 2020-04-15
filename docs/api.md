---
title: JSON API documentation
layout: nodenv_default
permalink: /docs/api/
---
## Formulae
### List formulae metadata for all {{ site.taps.core.repo }} formulae
List the `brew info --json=v1` output for all current {{ site.taps.core.fullname }} formulae.

```
GET {{ site.api.root }}/api/formula.json
```

#### Response
```json
[
  ...
  {
    "name": "nodenv-update",
    "full_name": "nodenv/nodenv/nodenv-update",
    "oldname": null,
    "aliases": [],
    "versioned_formulae": [],
    "desc": "Update nodenv plugins not installed with Homebrew",
    "homepage": "https://github.com/charlesbjohnson/nodenv-update",
    "versions": {
      "stable": "1.0.0",
      "devel": null,
      "head": "HEAD",
      "bottle": false
    },
    "urls": {},
    "revision": 0,
    "version_scheme": 0,
    "bottle": {},
    "keg_only": false,
    "bottle_disabled": false,
    "options": [],
    "build_dependencies": [],
    "dependencies": [
      "nodenv"
    ],
    "recommended_dependencies": [],
    "optional_dependencies": [],
    "uses_from_macos": [],
    "requirements": [],
    "conflicts_with": [],
    "caveats": null,
    "installed": [],
    "linked_keg": null,
    "pinned": false,
    "outdated": false
  },
  ...
]
```

### Get formula metadata for a {{ site.taps.core.repo }} formula
Get the `brew info --json=v1` output for a single, current {{ site.taps.core.fullname }} formula with an extra `analytics` key with analytics data.

```
GET {{ site.api.root }}/api/formula/${FORMULA}.json
```

#### Variables
- `${FORMULA}`: the name of the formula e.g. `wget`

#### Response
```json
{
  "name": "nodenv-update",
  "full_name": "nodenv/nodenv/nodenv-update",
  "oldname": null,
  "aliases": [],
  "versioned_formulae": [],
  "desc": "Update nodenv plugins not installed with Homebrew",
  "homepage": "https://github.com/charlesbjohnson/nodenv-update",
  "versions": {
    "stable": "1.0.0",
    "devel": null,
    "head": "HEAD",
    "bottle": false
  },
  "urls": {},
  "revision": 0,
  "version_scheme": 0,
  "bottle": {},
  "keg_only": false,
  "bottle_disabled": false,
  "options": [],
  "build_dependencies": [],
  "dependencies": [
    "nodenv"
  ],
  "recommended_dependencies": [],
  "optional_dependencies": [],
  "uses_from_macos": [],
  "requirements": [],
  "conflicts_with": [],
  "caveats": null,
  "installed": [],
  "linked_keg": null,
  "pinned": false,
  "outdated": false,
  "analytics": {
    "install": {
      "30d": {
        "nodenv-update": 0
      },
      "90d": {
        "nodenv-update": 0
      },
      "365d": {
        "nodenv-update": 0
      }
    },
    "install_on_request": {
      "30d": {
        "nodenv-update": 0
      },
      "90d": {
        "nodenv-update": 0
      },
      "365d": {
        "nodenv-update": 0
      }
    },
    "build_error": {
      "30d": {
        "nodenv-update": 0
      }
    }
  }
}
```


## Analytics
### List analytics events
List all analytics events for a specified category and number of days.

```
GET {{ site.api.root }}/api/analytics/${CATEGORY}/${DAYS}.json
```

#### Variables
- `${CATEGORY}`: the category of the analytics events, i.e.
  - `install`: the installation of all formulae
  - `install-on-request`: the requested installation of all formulae (i.e. not as a dependency of other formulae)
  - `cask-install`: the installation of all casks
  - `build-error`: the installation failure of all formulae
  - `os-version`: the macOS version of all machines that have submitted an event
- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

#### Response
```json
{
  "category": "install",
  "total_items": 13273,
  "start_date": "2020-03-06",
  "end_date": "2020-04-05",
  "total_count": 20029499,
  "items": [
    ...
    {
      "number": 3614,
      "formula": "nodenv/nodenv/node-build-update-defs",
      "count": "39",
      "percent": "0.00"
    },
    ...
  ]
}
```
