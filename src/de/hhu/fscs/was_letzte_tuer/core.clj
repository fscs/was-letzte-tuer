(ns de.hhu.fscs.was-letzte-tuer.core
  (:gen-class)
  (:require
   [babashka.fs :as fs]
   [compojure.core :refer [GET POST routes]]
   [compojure.route :as route]
   [selmer.parser :as t]
   [de.hhu.fscs.was-letzte-tuer.database :as db]
   [ring.adapter.jetty :as jetty]
   [ring.util.response :as res]
   [java-time.api :as time]
   [ring.middleware.defaults :refer [api-defaults wrap-defaults]]))

(def app-state (atom {}))

(def date-formatter (java.time.format.DateTimeFormatter/ofPattern "dd.MM.yyyy 'um' HH:mm"))

(defn zoned-date [date]
  (time/zoned-date-time date "Europe/Berlin"))

(defn normalize-date [{status :status date :time}]
  {:status status :time (zoned-date date)})

(defn accurate? [{date :time}]
  (let [diff (time/duration date (zoned-date (time/local-date-time)))
        diff-minutes (time/as diff :minutes)]
    (< diff-minutes 10)))

(def default-status {:status :maybe :time (zoned-date (time/local-date 1970))})

(defn query-status []
  (or
   (db/status (:db @app-state))
   default-status))

(defn current-status []
  (let [status (normalize-date (query-status))]
    (if (accurate? status)
      status
      (assoc status :status :maybe))))

(defn format-status [{status :status date :time}]
  {:status status :time (.format date-formatter date)})

(defn site []
  (-> (res/response (t/render-file "template.html" (format-status (current-status))))
      (res/header "CacheControl" "max-age=60")
      (res/content-type "text/html")))

(def handler
  (routes
   (GET "/" [] (site))
   (GET "/now" [] (name (:status (current-status))))
   (POST "/update" [status] (db/update-status (:db @app-state) (keyword status)))
   (POST "/gc" []
     (db/gc (:db @app-state)
            (time/java-date (time/- (time/instant) (time/duration 60 :days))))
     "here are two pictures. one is your database, the other one is a garbage dump in the philippines")
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
