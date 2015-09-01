
elementary_dark = null
update_from_hash = ->
	if m = location.hash.match /theme=([\w\-]*)/
		theme = m[1]
		theme_link = document.getElementById "theme"
		theme_link.href = "styles/themes/#{theme}.css"
		
		# if theme is "elementary"
		if theme is "elementary-dark"
			# if not elementary_dark?
				# elementary_dark = document.createElement "link"
				# elementary_dark.rel = "stylesheet"
				# elementary_dark.href = "lib/elementary-dark.css"
				# document.head.appendChild elementary_dark
				setInterval ->
					for button in document.querySelectorAll "button"
						button.classList.add "button"
					for tc in document.querySelectorAll ".track-controls"
						tc.classList.add "linked"
					for tc in document.querySelectorAll ".track-content"
						tc.classList.add "notebook"
				, 150

window.addEventListener "hashchange", update_from_hash
update_from_hash()

React.render (E AudioEditor), document.body
