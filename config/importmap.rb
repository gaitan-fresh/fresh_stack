# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "ai_summarizer", to: "ai_summarizer.js"
pin "vote_animations", to: "vote_animations.js"
pin "image_uploader", to: "image_uploader.js"
pin "image_lightbox", to: "image_lightbox.js"
pin "image_management", to: "image_management.js"
