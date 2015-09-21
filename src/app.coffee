
themes =
	"elementary": "elementary"
	"elementary Dark": "elementary-dark"
	"[Retro] Aqua": "retro/aqua"
	"[Retro] Green": "retro/green"
	"[Retro] Chroma": "retro/chroma"
	"[Retro] Amber": "retro/amber"
	"[Retro] Ambergine (aubergine + amber)": "retro/ambergine"
	"[Silly] Paper": "paper"

hacky_interval = null
update_from_hash = ->
	if m = location.hash.match /theme=([\w\-./]*)/
		theme = m[1]
		theme_link = document.getElementById "theme"
		theme_link.href = "styles/themes/#{theme}.css"
		
		if theme.match /elementary/
			unless hacky_interval
				hacky_interval = setInterval ->
					requestAnimationFrame ->
						for tc in document.querySelectorAll ".track-content"
							tc.classList.add "notebook"
						for ae in document.querySelectorAll ".audio-editor"
							ae.classList.add "window-frame"
							ae.classList.add "active"
							ae.style.borderRadius = "0"
						#for aec in document.querySelectorAll ".audio-editor .controls"
							#aec.classList.add "secondary-toolbar"
							#aec.classList.add "titlebar"
				, 150

window.addEventListener "hashchange", update_from_hash
update_from_hash()

set_theme = (theme)->
	location.hash = "theme=#{theme}"

React.render (E AudioEditor, {themes, set_theme}), document.body
