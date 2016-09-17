
fs = require("fs")
postcss = require("postcss")
at_import = require("postcss-import")
extend = require("postcss-extend")

build_theme = (theme_name, theme_path)->
	input_file_path = "styles/themes/#{theme_path}"
	output_file_path = "build/themes/#{theme_path}"
	css = fs.readFileSync(input_file_path, "utf8")
	
	postcss()
		.use(at_import())
		.use(extend())
		.process css,
			from: input_file_path
		.then (result)->
			fs.writeFileSync(output_file_path, result.css, "utf8")
			console.log "Wrote #{output_file_path}"

themes =
	"elementary": "elementary.css"
	"elementary Dark": "elementary-dark.css"
	"Monochrome Aqua": "retro/aqua.css"
	"Monochrome Green": "retro/green.css"
	"Monochrome Amber": "retro/amber.css"
	"Ambergine (aubergine + amber)": "retro/ambergine.css"

fs.writeFileSync "build/themes.json", JSON.stringify(themes, null, "\t"), "utf8"

for theme_name, theme_path of themes
	build_theme(theme_name, theme_path)
