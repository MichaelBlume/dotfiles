{:user {:plugins [[cider/cider-nrepl "0.8.2"]
                  [lein-cloverage "1.0.9"]
                  [lein-kibit "0.1.2"]
                  [lein-bikeshed "0.2.0"]
                  [lein-pprint "1.1.1"]
                  [lein-nevam "0.1.2"]
                  [lein-try "0.4.3"]
                  [lein-ancient "0.6.10"]
;                  [venantius/ultra "0.1.9"]
                  [lein-oneoff "0.3.1"]
                  [jonase/eastwood "0.2.4"]
                  [lein-clojars "0.9.1"]]
        :injections  [(require 'pjstadig.humane-test-output)
                      (pjstadig.humane-test-output/activate!)]
        :ultra {:color-scheme :solarized_dark}
        :aliases {"aaa" ["ancient" ":all" ":allow-qualified"]
                  "ct" ["do" "check," "test"]
                  "rh" ["repl" ":headless"]}
        :repl-options  {:init  (do
                                 (require 'cljfmt.core)
                                 (require 'clojure.java.javadoc))}
        :dependencies [[slamhound "1.5.5" :exclusions [org.clojure/clojure]]
                       [cljfmt "0.5.6"]
                       [org.clojure/tools.trace "0.7.9" :exclusions [org.clojure/clojure]]
                       [pjstadig/humane-test-output "0.8.2" :exclusions [org.clojure/clojure]]
                       [editor-fns "1.0.0" :exclusions [org.clojure/clojure]]
                       [criterium "0.4.3" :exclusions [org.clojure/clojure]]]}}
