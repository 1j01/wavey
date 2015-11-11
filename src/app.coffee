
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

audio_buffers_by_clip_id = {}

@audio_buffer_for_clip = (clip_id)->
	audio_buffers_by_clip_id[clip_id]

do render = ->
	React.render (E AudioEditor, {tracks, themes, set_theme}), document.body

load_clip_data = (clip)->
	localforage.getItem "#{document_id}/#{clip.id}", (err, array_buffer)=>
		if err
			alert "Failed to load audio data.\n#{err.message}"
			console.error err
		else if array_buffer
			actx.decodeAudioData array_buffer, (buffer)=>
				audio_buffers_by_clip_id[clip.id] = buffer
				remove_alert "Not all tracks have finished loading."
				render()
		else
			alert "An audio clip is missing from storage."
			console.warn "An audio clip is missing from storage.", clip

localforage.getItem "#{document_id}/tracks", (err, trax)=>
	if err
		alert "Failed to load the document.\n#{err.message}"
		console.error err
	else if trax
		tracks = trax
		render()
		for track in tracks
			for clip in track.clips
				load_clip_data clip

@add_clip = (track_index, file)->
	reader = new FileReader
	reader.onload = (e)=>
		array_buffer = e.target.result
		id = GUID()
		
		localforage.setItem "#{document_id}/#{id}", array_buffer, (err)=>
			if err
				alert "Failed to store audio data.\n#{err.message}"
				console.error err
			else
				# TODO: optimize by parallelizing decoding and storing, but keep good error handling
				actx.decodeAudioData array_buffer, (buffer)=>
					audio_buffers_by_clip_id[id] = buffer
					clip = {
						time: 0
						id: id
					}
					tracks[track_index].clips.push clip
					localforage.setItem "#{document_id}/tracks", tracks, (err)=>
						if err
							alert "Failed to store track metadata.\n#{err.message}"
							console.error err
						else
							render()
		, (e)=>
			alert "Audio not playable or not supported."
			console.error e
	
	reader.onerror = (e)=>
		alert "Failed to read audio file."
		console.error e
	
	reader.readAsArrayBuffer file
