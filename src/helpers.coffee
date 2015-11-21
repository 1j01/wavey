
@E = ReactScript
@E.Component = React.Component

@scale = 90 # @TODO: zooming

@GUID = ->
	array = new Uint32Array 4
	crypto.getRandomValues array
	("00000000#{n.toString 16}".slice -8 for n in array).join ""

@closest = (elem, selector)->
	matches = elem.matches ? elem.webkitMatchesSelector ? elem.mozMatchesSelector ? elem.msMatchesSelector
	while elem
		return elem if matches.call elem, selector
		elem = elem.parentElement
	no

@get_clip_start_end = (clip)->
	clip_start = clip.time
	clip_end = clip.time + (clip.length ? AudioClip.recordings[clip.recording_id]?.length)
	{clip_start, clip_end}

window.AudioContext = window.AudioContext ? window.webkitAudioContext
navigator.getUserMedia = navigator.getUserMedia ? navigator.webkitGetUserMedia ? navigator.mozGetUserMedia
window.URL = window.URL ? window.webkitURL
