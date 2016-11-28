[![badge][apm]][package]
[![badge][chat]][#slack]

Modular Snippets
================
A modular solution to [snippets] in [Atom], including support for project-specific collections.

Any valid snippets [_[CSON]_ or JSON] file inside [`ATOM_HOME`]`/snippets/**` will be loaded automatically, or reloaded if modified.

This package does not interfere with the existing `snippets.cson`, so you can slowly transition to this more modular approach.

The Atom `Snippets…` menu item will be overridden to open your snippets folder in a new window, along with the default `snippets.cson` if it still exists.

The Atom `Snippets…` menu item will be overridden to open your snippets folder in a new window, along with the default `snippets.cson` if it still exists.

Project Snippets
----------------
Some snippets might only be relevant to a particular project, so it makes sense to store them with that project; these could then be committed to version control and shared between a team. These _local_ snippets are loaded from the first item found in the root of your project based on the following order:

* `[.]snippets.cson`
* `[.]snippets/**/*.cson`
* `snippets: {object}` in `package.json`
* `snippets: {object}` in your _[project-config]_

API
---
This package also provides a [service] to load any snippets `{object}`, file or folder…
~~~ js
// package.json
"consumedServices": {
  "modular-snippets": {
    "versions": {
      "^1.0.0": "consume"
    }
  }
},
~~~
~~~ coffee
# index.coffee
{Disposable} = require 'atom'

snippet = # {object}, file or folder.
  '.source.coffee':
    Snippet:
      prefix: 'prefix'
      body: 'snippet'

consumeSnippets: ({load}) ->
  load snippet
  new Disposable -> stopUsingService load
~~~

Install
-------
`apm install modular-snippets` or search “snippets” under packages within Atom.

License
-------
[MIT] © [Daniel Bayley]

Thanks to [@thibmaek] for the base repository.

[MIT]:              LICENSE.md
[Daniel Bayley]:    https://github.com/danielbayley
[atom]:             https://atom.io
[apm]:              https://img.shields.io/apm/v/modular-snippets.svg?style=flat-square
[package]:          https://atom.io/packages/modular-snippets
[chat]:             https://img.shields.io/badge/chat-atom.io%20slack-ff69b4.svg?style=flat-square
[#slack]:           https://atom-slack.herokuapp.com

[snippets]:         http://flight-manual.atom.io/using-atom/sections/snippets
[CSON]:             https://github.com/bevry/cson#what-is-cson
[`ATOM_HOME`]:      http://flight-manual.atom.io/using-atom/sections/basic-customization/#custom-home-location-with-an-environment-variable
[service]:          http://flight-manual.atom.io/behind-atom/sections/interacting-with-other-packages-via-services
[sync-settings]:    https://atom.io/packages/sync-settings
[project-config]:   https://github.com/danielbrodin/atom-project-manager/#local-settings-file
[gist]:             https://github.com/gist
[@thibmaek]:        https://atom.io/users/thibmaek
