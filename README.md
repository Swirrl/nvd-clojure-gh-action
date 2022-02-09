# Clojure NVD Dependency Check Action

A simple GitHub action to run
[nvd-clojure](https://github.com/rm-hull/nvd-clojure) and report an issue when
there are vulnerabilities reported.

## Warning

This action will create issues on the repository it is activated on. If
the repository is public then *the issue posted will be public*, and it will
look like this:

```
CVEs Found in owner/repo: [CRITICAL, HIGH, MEDIUM, LOW] #1
```

Ensure that you want this before activating this action on a public repository.

## Usage

Add a `.github/workflows/main.yml` to your project:

```yml
name: Clojure NVD Dependency Checking

on:
  workflow_dispatch:
  schedule:
    - cron: "0 1 * * 1-5"

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
      - name: Checkout Latest Commit
        uses: actions/checkout@v2.4.0

      - name: NVD Clojure
        uses: Swirrl/nvd-clojure-gh-action@master
        with:
          directories: sub-project-dir
          github_token: ${{ secrets.github_token }}
          ssh_private_key: ${{ secrets.ssh_private_key }}
          aws_access_key_id: ${{ secrets.aws_access_key_id }}
          aws_secret_access_key: ${{ secrets.aws_secret_access_key }}
```


## Supported Arguments

* `directories`: Space separated sub-directories to check. Defaults to the root of the repository.
* `github_token`: The only required argument. Can either be the default token, as seen above, or a personal access token with write access to the repository.
* `ssh_private_key`: Used to access private repositories over git/SSH, use the private key of the private repo's "Deploy Key".
* `aws_access_key_id`: Used to access S3 bucket maven repos.
* `aws_secret_access_key`: Used to access S3 bucket maven repos.

## Suppressing CVEs

Due to how dependency-check identifies libraries false positives may occur
(i.e. a CPE was identified that is incorrect).

Add a file in the Clojure project directory named `nvd-clojure-suppress.xml` to
specify CVE suppressions.

See the [DependencyCheck docs](https://jeremylong.github.io/DependencyCheck/general/suppression.html),
and the [example project](https://github.com/Swirrl/nvd-clojure-gh-action/tree/master/example)
for details.

## Licensing

Copyright © 2022 [Swirrl IT Ltd](https://swirrl.com)

Distributed under the [Eclipse Public License](https://github.com/Swirrl/nvd-clojure-gh-action/blob/master/LICENSE) either version 1.0 or (at your option) any later version.
