# Snatched and tweaked from 
# https://gist.github.com/jrmoran/1537200

fs            = require 'fs'
{exec, spawn} = require 'child_process'

# order of files in `inFiles` is important
config =
  srcDir:  'coffee'
  outDir:  'js'
  inFiles: [ 'color', 'imageCanvas', 'app' ]
  outFile: 'c'
  yuic:    'yuicompressor.jar'

outJS    = "#{config.outDir}/#{config.outFile}"
strFiles = ("#{config.srcDir}/#{file}.coffee" for file in config.inFiles).join ' '

# deal with errors from child processes
exerr  = (err, sout,  serr)->
  process.stdout.write err  if err
  process.stdout.write sout if sout
  process.stdout.write serr if serr

task 'doc', 'generate documentation for *.coffee files', ->
  exec "docco #{config.srcDir}/*.coffee", exerr

# this will keep the non-minified compiled and joined file updated as files in
# `inFile` change.
task 'watch', 'watch and compile changes in source dir', ->
  watch = exec "coffee -j #{outJS}.js -cw #{config.srcDir}"
  watch.stdout.on 'data', (data)->
    process.stdout.write data
    # Trim the data and minimize
    dsplit = data.split("\\")
    file = dsplit.pop()
    fsplit = file.split(".")
    filename = fsplit[0]
    exec "java -jar #{config.yuic} #{config.outDir}/#{filename}.js -o #{config.outDir}/#{filename}.min.js"

task 'build', 'join and compile *.coffee files', ->
  exec "coffee -j #{outJS}.js -c #{strFiles}", exerr

task 'min', 'minify compiled *.js file', ->
  exec "java -jar #{config.yuic} #{outJS}.js -o #{outJS}.min.js", exerr
  
task 'wjm', 'watch, join all, and compile changes in source dir, then minify', ->
  watch = exec "coffee -j #{outJS}.js -cw #{config.srcDir}/"
  watch.stdout.on 'data', (data) ->
    process.stdout.write data
    invoke 'min'

task 'bam', 'build and minify', ->
  invoke 'build'
  invoke 'min'

task 'test', 'runs jasmine tests', ->
  exec 'jasmine-node --coffee --verbose spec', exerr

# watch files and run tests automatically
task 'watch:test', 'watch and run tests', ->
  console.log 'watching...'

  whenChanged = (filename, fun)->
    fs.watchFile filename, (curr, prev)->
      fun() if curr.mtime > prev.mtime

  for f in config.inFiles
    whenChanged "#{f}.coffee", ->
      console.log "===== TEST #{new Date().toLocaleString()} ====="
      invoke 'test'
