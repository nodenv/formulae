# Homebrew Formulae

[Homebrew Formulae](https://formulae.brew.sh) is an online package browser for [Homebrew](https://brew.sh).

It displays all packages in [nodenv/homebrew-nodenv](https://github.com/nodenv/homebrew-nodenv) and [nodenv/homebrew-cask](https://github.com/nodenv/homebrew-cask).

## JSON API

It also provides a JSON API for all packages (or individual packages) in [nodenv/homebrew-nodenv](https://github.com/nodenv/homebrew-nodenv) and their related analytics. This JSON data is used for the creation of the HTML resources on this site.

Currently available:
- List formulae metadata for all homebrew-nodenv formulae
- Get formula metadata for a homebrew-nodenv formula
- List analytics events
- List analytics events for all homebrew-nodenv formulae

Read more in the [JSON API documentation](https://formulae.brew.sh/docs/api/).

## Usage
Open https://formulae.brew.sh/ in your web browser.

To instead run Homebrew Formulae locally, run:
```bash
git clone https://github.com/nodenv/formulae.brew.sh
cd formulae.brew.sh
bundle install
bundle exec jekyll serve
```

## License
Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
