
fs = require "fs"
async = require "async"
postcss = require "postcss"
# sugarss = require "sugarss"
{createDebugger, matcher} = require "postcss-debug"

watchify = require 'watchify'
browserify = require 'browserify'
coffeeify = require 'coffeeify'
gulp = require 'gulp'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
gutil = require 'gulp-util'
sourcemaps = require 'gulp-sourcemaps'

browserify_options =
	entries: ['./src/app.coffee']
	extensions: ['.coffee']
	debug: yes

opts = Object.assign {}, watchify.args, browserify_options
b = watchify browserify opts 

b.transform coffeeify
	# bare: no
	# header: yes
	

bundle = ->
	b.bundle()
		# log errors if they happen
		.on 'error', gutil.log.bind(gutil, 'Browserify Error')
		.pipe source('bundle.js')
		# "optional, remove if you don't need to buffer file contents"
		.pipe buffer()
		# .pipe sourcemaps.init(loadMaps: true) # loads map from browserify file
		# .pipe sourcemaps.write('./') # writes .map file
		.pipe gulp.dest('./build')

gulp.task 'watch-scripts', bundle
b.on 'update', bundle # on any dep update, runs the bundler
b.on 'log', gutil.log # output build logs

gulp.task 'watch-styles', ->
	gulp.watch 'styles/**/*', ['styles']

gulp.task 'styles', (callback)->
	
	# TODO: preprocess non-theme-specific css
	
	debug = createDebugger([
		matcher.regex(/amber/)
	])
	
	build_theme = (theme_path, callback)->
		input_file_path = "styles/themes/#{theme_path}"
		output_file_path = "build/themes/#{theme_path}"
		fs.readFile input_file_path, "utf8", (err, css)->
			return callback(err) if err
			
			postcss(debug([
				require("postcss-import")
				# require("postcss-easy-import")
				require("postcss-advanced-variables")
				require("postcss-color-function")
				require("postcss-extend")
				require("postcss-url")(url: "rebase")
			]))
			.process(css, from: input_file_path, to: output_file_path) #, parser: sugarss
			.then (result)->
				fs.writeFile output_file_path, result.css, "utf8", (err)->
					return callback(err) if err
					gutil.log "Wrote #{output_file_path}"
					callback(null)
			.catch(callback)
	
	# TODO: probably move this into a JSON file as the canonical source
	themes =
		"elementary": "elementary.css"
		"elementary Dark": "elementary-dark.css"
		"Monochrome Aqua": "retro/aqua.css"
		"Monochrome Green": "retro/green.css"
		"Monochrome Amber": "retro/amber.css"
		"Ambergine (aubergine + amber)": "retro/ambergine.css"
	
	fs.writeFileSync("build/themes.json", JSON.stringify(themes, null, "\t"), "utf8")
	
	async.eachOf themes,
		(theme_path, theme_name, callback)->
			build_theme(theme_path, callback)
		(err)->
			return callback(err) if err
			debug.inspect()
			callback()


gulp.task 'default', ['watch-scripts', 'watch-styles']

