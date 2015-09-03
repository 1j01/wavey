
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
				, 150

window.addEventListener "hashchange", update_from_hash
update_from_hash()

React.render (E AudioEditor), document.body
