(ns dev
  (:require [clojure.string :as string]
            [clj-http.lite.client :as http]
            [clj-commons.digest :as digest]
            [clojure.data.json :as json]
            [clojure.java.io :as io]
            [clojure.pprint :refer [pprint]]))

(def target-path
  (or (System/getenv "TARGET_PATH")
      "/nvd/target/nvd"))

(def target (io/file target-path))
(def file (io/file target "dependency-check-report.json"))

(def vulns
  (with-open [r (io/reader file)]
    (json/read-json r keyword)))

(def vuln-fmt "  - [%s](https://nvd.nist.gov/vuln/detail/%s) [%s]")

(def issue-markdown
  (->> (:dependencies vulns)
       (filter :vulnerabilities)
       (map (fn [{:keys [fileName vulnerabilities]}]
              (str fileName \newline
                   (->> vulnerabilities
                        (sort-by (comp :baseScore :cvssv3) >)
                        (map (fn [{:keys [name severity]}]
                               (format vuln-fmt name name severity)))
                        (string/join "\n")))))
       (string/join "\n\n")))

(def severities
  (->> (:dependencies vulns)
       (mapcat :vulnerabilities)
       (filter :cvssv3)
       (sort-by (comp :baseScore :cvssv3) >)
       (map :severity)
       (distinct)))

(def issue-hash
  (digest/md5 issue-markdown))

(def token (System/getenv "GITHUB_TOKEN"))

(def repo (System/getenv "GITHUB_REPOSITORY"))

(def project (System/getenv "PROJECT"))

(defn api [f repo path token request]
  (let [url (format "https://api.github.com/repos/%s%s" repo path)]
    (f url
       (merge request
              {:headers {"Authorization" (str "token " token)
                          "Accept" "application/vnd.github.v3+json"
                          "Content-Type" "application/json"}}))))

(defn GET [repo path token & {:keys [query-params] :as req}]
  (api http/get repo path token req))

(defn POST [repo path token & {:keys [query-params body] :as req}]
  (api http/post repo path token (update req :body json/write-str)))

(def content-hash
  (str "Content Hash: " issue-hash))

(defn create-issue [repo severities hash markdown]
  (let [repo-name (second (string/split repo #"/"))
        path (str repo-name (some->> project (str "/")))]
    (POST repo "/issues" token
          :body {:title (format "CVEs Found in %s: [%s]"
                                path
                                (string/join ", " severities))
                 :labels ["CVE" "dependencies"]
                 :body (str content-hash "\n\n" markdown)})))

(defn list-issues [repo]
  (-> (GET repo "/issues" token
           :query-params {:labels "CVE" :creator "github-actions[bot]"})
      (:body)
      (json/read-str :key-fn keyword)))

(defn find-issue [repo pred]
  (some pred (list-issues repo)))

(defn hashed? [{:keys [body]}]
  (.startsWith body content-hash))

(defn duplicate? [repo]
  (find-issue repo hashed?))

(defn -main [& args]
  (when-not (duplicate? repo)
    (create-issue repo severities issue-hash issue-markdown)))
