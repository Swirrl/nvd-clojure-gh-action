FROM cimg/base:2022.01

WORKDIR /github/workspace
COPY . /nvd

ENTRYPOINT ["bash", "/nvd/bin/nvd-clojure-gh-action.sh"]
