(ns de.hhu.fscs.was-letzte-tuer.core
  (:gen-class)
  (:require
   [babashka.fs :as fs]
   [compojure.core :refer [GET POST routes]]
   [compojure.route :as route]
   [selmer.parser :as t]
   [de.hhu.fscs.was-letzte-tuer.database :as db]
   [ring.adapter.jetty :as jetty]
   [ring.middleware.defaults :refer [api-defaults wrap-defaults]]))

(def app-state (atom {}))

(defn site [] (let [status (or (db/status (:db @app-state)) :closed)]
                (t/render-file "template.html" {:status status})))

(def handler
  (routes
   (GET "/" [] (site))
   (GET "/now" [] (name (or (db/status (:db @app-state)) :closed)))
   (POST "/update" [status] (db/update-status (:db @app-state) (keyword status)))
   (route/resources "/static")
   (route/not-found "<h1>Page not found</h1>")))

(def app (wrap-defaults handler api-defaults))

(defn -main [& [port dbStore]]
  (let [port (Integer. (or port 8080))
        dbPath (or dbStore (.toString (fs/path (fs/cwd) "database")))
        db (db/connect dbPath)]
    (println "running on port" port "using database path" dbPath)
    (reset! app-state {:db db})
    (jetty/run-jetty app {:port port})))
