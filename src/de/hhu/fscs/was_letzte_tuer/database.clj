(ns de.hhu.fscs.was-letzte-tuer.database
  (:require [datahike.api :as hike]))

(defn connect [path] (let [cfg {:store {:backend :file :path (.toString path)}
                                :initial-tx [{:db/ident :was-letzte-tuer/status
                                              :db/valueType :db.type/keyword
                                              :db/cardinality :db.cardinality/one}]}]
                       (or (hike/database-exists? cfg) (hike/create-database cfg))
                       (hike/connect cfg)))

(defn status [db]
  (let [last-tx (ffirst
                 (hike/q
                  '[:find (max ?tx) :where [_ :was-letzte-tuer/status ?s ?tx]] @db))]
    (first
     (hike/q
      '[:find ?status ?time
        :keys status time
        :in $ ?tx
        :where
        [_ :was-letzte-tuer/status ?status ?tx]
        [?tx :db/txInstant ?time]]
      @db
      last-tx))))

(defn update-status [db status]
  (assert (or (= :closed status) (= :open status)))
  (hike/transact db [{:was-letzte-tuer/status status}]))
