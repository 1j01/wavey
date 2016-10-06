
fs = require "fs"
async = require "async"
postcss = require "postcss"
# sugarss = require "sugarss"
# precss = require "precss"
# url = require "postcss-url"
{createDebugger, matcher} = require "postcss-debug"

# TODO: preprocess non-theme-specific css, watch automatically, and use SugarSS

debug = createDebugger([
	matcher.regex(/amber/)
])

build_theme = (theme_path, callback)->
	input_file_path = "styles/themes/#{theme_path}"
	output_file_path = "build/themes/#{theme_path}"
	fs.readFile input_file_path, "utf8", (err, css)->
		return callback(err) if err
		
		postcss(debug([
			# precss()
			require("postcss-import")
			# require("postcss-easy-import")
			# require("postcss-partial-import")
			require("postcss-advanced-variables")
			require("postcss-color-function")
			require("postcss-extend")
			require("postcss-url")(url: "rebase")
		]))
		# postcss([...], parser: sugarss)
		.process(css, from: input_file_path, to: output_file_path)
		.then (result)->
			fs.writeFile output_file_path, result.css, "utf8", (err)->
				return callback(err) if err
				console.log "Wrote #{output_file_path}"
				callback(null)
		.catch(callback)

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
		return console.error(err) if err
		debug.inspect()
