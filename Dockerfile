FROM cimg/clojure:1.10.3

USER root
WORKDIR /github/workspace
COPY . /nvd

ENTRYPOINT ["bash", "/nvd/bin/nvd-clojure-gh-action.sh"]
