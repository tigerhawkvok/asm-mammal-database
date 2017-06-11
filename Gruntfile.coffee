#spawn = require('child_process').spawn
#require("load-grunt-tasks")(grunt)

module.exports = (grunt) ->
  # Gruntfile
  # https://github.com/sindresorhus/grunt-shell
  grunt.loadNpmTasks("grunt-shell")
  # https://www.npmjs.com/package/grunt-contrib-coffee
  grunt.loadNpmTasks("grunt-contrib-coffee")
  # https://github.com/gruntjs/grunt-contrib-watch
  grunt.loadNpmTasks("grunt-contrib-watch")
  grunt.loadNpmTasks("grunt-contrib-uglify")
  grunt.loadNpmTasks("grunt-contrib-cssmin")
  # Validators
  grunt.loadNpmTasks('grunt-bootlint')
  grunt.loadNpmTasks('grunt-html')
  grunt.loadNpmTasks('grunt-string-replace')
  grunt.loadNpmTasks('grunt-postcss')
  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks("grunt-phplint")
  # https://github.com/Polymer/grunt-vulcanize
  grunt.loadNpmTasks('grunt-vulcanize')
  grunt.loadNpmTasks('grunt-php-cs-fixer')
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    shell:
      options:
        stderr: false
      bower:
        command: ["bower install", "bower update"].join("&&")
      yarn:
        command: ["yarn install", "yarn upgarde"].join("&&")
      movesrc:
        command: ["cp js/c.src.coffee js/maps/c.src.coffee"].join("&&")
      dumpver:
        command: ["git describe --abbrev=0 > currentVersion"].join("&&")
    postcss:
      options:
        processors: [
          require('autoprefixer')({browsers: 'last 2 versions'})
          ]
      dist:
        src: "css/main.css"
      drop:
        src: "css/shadow-dropzone.css"
    vulcanize:
      default:
        options:
          stripComments: true
          #inlineCss: true
          #abspath: "cndb/"
        files:
          "build.html": "index.html"
    phpcs:
      application:
        src: [
          "api.php"
          ]
      options:
        standard: "PSR2"
    phpcsfixer:
      app:
        dir: [
          "api.php"
          "admin-api.php"
          "admin-login.php"
          "index.php"
          "species-account.php"
          "meta.php"
          "400.php"
          "modular/"
          ]
      users:
        dir: [
          "admin/api.php"
          "admin/app_api.php"
          "admin/app_handlers.php"
          "admin/async_login_handler.php"
          "admin/braintree_billing.php"
          "admin/index.php"
          "admin/login.php"
          "admin/test_page.php"
          "admin/handlers/"
          ]
      core:
        dir: [
          "core/"
          ]
      pdf:
        dir: [
          "pdf/pdfwrapper.php"
          ]
      options:
        rules: "@PSR2"
    uglify:
      vulcanize:
        options:
          sourceMap:true
          sourceMapName:"js/maps/app.js.map"
        files:
          "js/app.min.js":["app-prerelease.js"]
      combine:
        options:
          sourceMap:true
          sourceMapIncludeSources:true
          sourceMapIn: (fileIn) ->
            fileName = fileIn.split("/").pop()
            fileNameArr = fileName.split(".")
            fileNameArr.pop()
            fileId = fileNameArr.join(".")
            "js/maps/#{fileId}.js.map"
        files:
          "js/combined.min.js":["js/c.js","js/admin.js", "js/charts.js","js/download.js","bower_components/purl/purl.js","bower_components/xmlToJSON/lib/xmlToJSON.js","bower_components/jquery-cookie/jquery.cookie.js"]
          "js/app.min.js":["js/c.js","js/admin.js", "js/charts.js", "js/download.js"]
      dist:
        options:
          sourceMap:true
          sourceMapIncludeSources:true
          sourceMapIn: (fileIn) ->
            fileName = fileIn.split("/").pop()
            fileNameArr = fileName.split(".")
            fileNameArr.pop()
            fileId = fileNameArr.join(".")
            "js/maps/#{fileId}.js.map"
          compress:
            # From https://github.com/mishoo/UglifyJS2#compressor-options
            dead_code: true
            unsafe: true
            conditionals: true
            unused: true
            loops: true
            if_return: true
            drop_console: false
            warnings: true
            properties: true
            sequences: true
            cascade: true
        files:
          "js/c.min.js":["js/c.js"]
          "js/download.min.js":["js/download.js"]
          "js/terminal.min.js":["js/terminal.js"]
          "js/admin.min.js":["js/admin.js"]
          "js/serviceWorker.min.js":["js/serviceWorker.js"]
          "js/charts.min.js":["js/charts.js"]
      minpurl:
        options:
          sourceMap:true
          sourceMapName:"js/maps/purl.map"
        files:
          "js/purl.min.js": ["bower_components/purl/purl.js"]
      minmarkdown:
        options:
          sourceMap:true
          sourceMapName:"js/maps/markdown.map"
        files:
          "js/markdown.min.js": ["bower_components/markdown/lib/markdown.js"]
      minxmljson:
        options:
          sourceMap:true
          sourceMapName:"js/maps/xmlToJSON.map"
        files:
          "js/xmlToJSON.min.js": ["bower_components/xmlToJSON/lib/xmlToJSON.js"]
      minjcookie:
        options:
          sourceMap:true
          sourceMapName:"js/maps/jquery.cookie.map"
        files:
          "js/jquery.cookie.min.js": ["bower_components/jquery-cookie/jquery.cookie.js"]
    less:
      # https://github.com/gruntjs/grunt-contrib-less
      options:
        sourceMap: true
        outputSourceFiles: true
        banner: "/*** Compiled from LESS source ***/\n\n"
      files:
        dest: "css/main.css"
        src: ["less/main.less"]
    cssmin:
      options:
        sourceMap: true
        advanced: false
      target:
        files:
          "css/main.min.css":["css/main.css"]
          "css/dropzone.min.css":["css/shadow-dropzone.css"]
    coffee:
      compile:
        options:
          bare: true
          join: true
          sourceMapDir: "js/maps"
          sourceMap: true
        files:
          "js/c.js":["coffee/core.coffee","coffee/search.coffee","coffee/terminal.coffee"]
          "js/terminal.js": ["coffee/terminal.coffee"]
          "js/download.js":["coffee/download.coffee"]
          "js/admin.js":"coffee/admin.coffee"
          "js/serviceWorker.js":["coffee/core-worker.coffee","coffee/serviceWorker.coffee"]
          "js/charts.js":["coffee/charts.coffee"]
    watch:
      scripts:
        files: ["coffee/*.coffee"]
        tasks: ["coffee:compile","uglify:dist","shell:movesrc"]
      styles:
        files: ["less/main.less"]
        tasks: ["less","postcss","cssmin"]
      html:
        files: ["index.html","admin-page.html"]
        tasks: ["bootlint","htmllint"]
      app:
        files: ["app.html"]
        tasks: ["bootlint","shell:vulcanize","uglify:vulcanize","string-replace:vulcanize"]
    phplint:
      root: ["*.php", "helpers/*.php", "core/*/*.php", "core/*.php"]
      admin: ["admin/*.php", "admin/handlers/*.php", "admin/core/*.php", "admin/core/*/*.php"]
      pdf: ["pdf/*.php"]
    bootlint:
      options:
        stoponerror: false
        relaxerror: ['W009']
      files: ["index.html","admin-page.html"]
    htmllint:
      all:
        src: ["index.html","admin-page.html"]
      options:
        ignore: [/XHTML element “[a-z-]+-[a-z-]+” not allowed as child of XHTML element.*/,"Bad value “X-UA-Compatible” for attribute “http-equiv” on XHTML element “meta”.",/Bad value “theme-color”.*/,/Bad value “import” for attribute “rel” on element “link”.*/,/Element “.+” not allowed as child of element*/,/.*Illegal character in query: not a URL code point./]
  ## Now the tasks
  grunt.registerTask("default",["watch"])
  grunt.registerTask("vulcanize-app","Vulcanize web components",["vulcanize","string-replace:vulcanize"])
  grunt.registerTask("compile","Compile coffeescript",["coffee:compile","uglify:dist","shell:movesrc"])
  ## The minification tasks
  # Part 1
  grunt.registerTask("minifyIndependent","Minify Bower components that aren't distributed min'd",["uglify:minpurl","uglify:minxmljson","uglify:minjcookie"])
  # Part 2
  grunt.registerTask("minifyBulk","Minify all the things",["uglify:combine","uglify:dist","less","postcss","cssmin"])
  grunt.registerTask "css", "Process LESS -> CSS", ["less","postcss","cssmin"]
  # Main call
  grunt.registerTask "minify","Minify all the things",->
    grunt.task.run("minifyIndependent","minifyBulk")
  ## Global update
  # Bower
  grunt.registerTask("updateBower","Update bower dependencies",["shell:bower"])
  grunt.registerTask("updateYarn","Update Yarn dependencies",["shell:yarn"])
  # Minify the bower stuff in case it changed
  grunt.registerTask "update","Update dependencies", ->
    grunt.task.run("updateYarn","updateBower","minify")
  ## Deploy
  grunt.registerTask "qbuild","CoffeeScript and CSS", ->
    # ,"vulcanize"
    grunt.task.run("phplint","compile","css")
  grunt.registerTask "build","Prepare for deployment", ->
    # ,"vulcanize"
    grunt.task.run("update","qbuild","minify","phpcsfixer","shell:dumpver")
