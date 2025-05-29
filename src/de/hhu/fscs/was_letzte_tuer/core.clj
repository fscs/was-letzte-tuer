(ns de.hhu.fscs.was-letzte-tuer.core
  (:require
    [clojure.string :as string])
  (:gen-class))

(defn -main
  [& args]
  (println (str "Hello from " (string/upper-case "clojure!!!"))))
