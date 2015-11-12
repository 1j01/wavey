
@actx = new (
	window.AudioContext ?
	window.webkitAudioContext ?
	window.mozAudioContext ?
	window.oAudioContext ?
	window.msAudioContext
)

themes =
	"elementary": "elementary"
	"elementary Dark": "elementary-dark"
	"Monochrome Aqua": "retro/aqua"
	"Monochrome Green": "retro/green"
	"Monochrome Amber": "retro/amber"
	"Ambergine (aubergine + amber)": "retro/ambergine"
	"Chroma": "retro/chroma"

patch_elementary_classes = ->
	requestAnimationFrame ->
		for el in document.querySelectorAll ".track-content"
			el.classList.add "notebook"
		for el in document.querySelectorAll ".audio-editor .controls"
			el.classList.add "titlebar"
		for el in document.querySelectorAll ".menu-item"
			el.classList.add "menuitem"
		for el in document.querySelectorAll ".dropdown-menu"
			el.classList.add "window-frame"
			el.classList.add "active"
			el.classList.add "csd"

hacky_interval = null
update_from_hash = ->
	if m = location.hash.match /theme=([\w\-./]*)/
		theme = m[1]
		theme_link = document.getElementById "theme"
		theme_link.href = "styles/themes/#{theme}.css"
		
		if theme.match /elementary/
			unless hacky_interval
				hacky_interval = setInterval patch_elementary_classes, 150
				window.addEventListener "mousedown", patch_elementary_classes
				window.addEventListener "mouseup", patch_elementary_classes

window.addEventListener "hashchange", update_from_hash
update_from_hash()

set_theme = (theme)->
	location.hash = "theme=#{theme}"

tracks = [
	{clips: []}
]
document_id = (location.hash.match(/document=([\w\-./]*)/) ? [0, "d1"])[1]

undos = []
redos = []

save_tracks = ->
	render()
	localforage.setItem "#{document_id}/tracks", tracks, (err)=>
		if err
			alert "Failed to store track metadata.\n#{err.message}"
			console.error err
		else
			render()
	localforage.setItem "#{document_id}/undos", undos
	localforage.setItem "#{document_id}/redos", redos
	# @TODO: error handling

@undoable = ->
	redos = []
	undos.push JSON.parse JSON.stringify tracks
	save_tracks()

@undo = ->
	return unless undos.length
	redos.push JSON.parse JSON.stringify tracks
	tracks = undos.pop()
	save_tracks()
	AudioClip.load_clips(tracks, document_id)
	# @TODO: AudioEditor#update_playback()

@redo = ->
	return unless redos.length
	undos.push JSON.parse JSON.stringify tracks
	tracks = redos.pop()
	save_tracks()
	AudioClip.load_clips(tracks, document_id)
	# @TODO: AudioEditor#update_playback()


do @render = ->
	React.render (E AudioEditor, {document_id, tracks, save_tracks, themes, set_theme}), document.body

localforage.getItem "#{document_id}/tracks", (err, _tracks)=>
	if err
		alert "Failed to load the document.\n#{err.message}"
		console.error err
	else if _tracks
		tracks = _tracks
		render()
		AudioClip.load_clips(tracks, document_id)
		
		localforage.getItem "#{document_id}/undos", (err, _undos)=>
			if err
				alert "Failed to load undo history.\n#{err.message}"
				console.error err
			else if _undos
				undos = _undos
				render()
		
		localforage.getItem "#{document_id}/redos", (err, _redos)=>
			if err
				alert "Failed to load redo history.\n#{err.message}"
				console.error err
			else if _redos
				redos = _redos
				render()
