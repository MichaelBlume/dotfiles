{:user {:plugins [[cider/cider-nrepl "0.8.2"]
                  [lein-cloverage "1.0.2"]
                  [lein-kibit "0.0.8"]
                  [lein-bikeshed "0.2.0"]
                  [lein-try "0.4.3"]
                  [lein-ancient "0.6.3"]
                  [jonase/eastwood "0.2.1"]
                  [lein-clojars "0.9.1"]]
        :injections  [(require 'pjstadig.humane-test-output)
                      (pjstadig.humane-test-output/activate!)]
        :aliases {"aaa" ["ancient" ":all" ":allow-qualified"]}
        :dependencies [[slamhound "1.5.5" :exclusions [org.clojure/clojure]]
                       [pjstadig/humane-test-output "0.6.0" :exclusions [org.clojure/clojure]]
                       [mike-clj "1.0.0-SNAPSHOT" :exclusions [org.clojure/clojure]]
                       [criterium "0.4.3" :exclusions [org.clojure/clojure]]]}}
