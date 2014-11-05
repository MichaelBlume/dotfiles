{:user {:plugins [[cider/cider-nrepl "0.7.0"]
                  [lein-cloverage "1.0.2"]
                  [lein-kibit "0.0.8"]
                  [lein-bikeshed "0.1.8"]
                  [lein-try "0.4.3"]
                  [lein-ancient "0.5.5"]
                  [jonase/eastwood "0.1.4"]
                  [lein-clojars "0.9.1"]]
        :injections  [(require 'pjstadig.humane-test-output)
                      (pjstadig.humane-test-output/activate!)]
        :dependencies [[slamhound "1.5.5"]
                       [pjstadig/humane-test-output "0.6.0"]
                       [mike-clj "1.0.0-SNAPSHOT"]
                       [com.cemerick/pomegranate "0.3.0"]
                       [criterium "0.4.3"]]}}
