
React = require "react"
ReactScript = require "react-script"

exports.E = ReactScript
exports.E.Component = React.Component

exports.GUID = ->
	array = new Uint32Array 4
	crypto.getRandomValues array
	("00000000#{n.toString 16}".slice -8 for n in array).join ""

# has to be after exports.E is defined (@XXX)
AudioClip = require "./components/AudioClip.coffee" # for class-level interface (@XXX)

exports.get_clip_start_end = (clip)->
	clip_start = clip.position
	clip_end = clip.position + (clip.length ? AudioClip.recordings[clip.recording_id]?.length)
	{clip_start, clip_end}

exports.normal_tracks_in = (tracks)->
	track for track in tracks when track.type isnt "beat"
