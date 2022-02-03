FROM clojure:openjdk-8-tools-deps

WORKDIR /github/workspace
COPY . /nvd

ENTRYPOINT ["bash", "/nvd/bin/nvd-clojure-gh-action.sh"]
