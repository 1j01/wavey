
{E, Component} = require "../helpers.coffee"
Track = require "./Track.coffee"
AudioClip = require "./AudioClip.coffee"
audio_clips = require "../audio-clips.coffee"
Range = require "../Range.coffee"

module.exports =
class AudioTrack extends Component
	render: ->
		{track, selection, scale, editor} = @props
		{clips, muted, pinned} = track
		
		E Track, {track, editor},
			E ".audio-clips",
				style:
					position: "relative"
					height: 80 # = canvas height
					boxSizing: "content-box"
				
				for clip, i in clips
					recording = audio_clips.recordings[clip.recording_id]
					recording_length =
						if recording?
							if recording.length?
								recording.length
							else
								one_channel = recording.chunks[0]
								num_chunks = one_channel.length
								if num_chunks > 0
									chunk_size = one_channel[0].length
									chunk_size * num_chunks / recording.sample_rate
								else
									0
					
					E AudioClip,
						key: clip.id
						position: clip.position
						length: clip.length ? recording_length
						offset: clip.offset ? 0
						scale: scale
						sample_rate:
							if clip.recording_id?
								recording?.sample_rate
							else
								audio_clips.audio_buffers[clip.audio_id]?.sampleRate
						data:
							if clip.recording_id?
								if recording?
									recording.chunks
								else
									null
							else
								audio_clips.audio_buffers[clip.audio_id]
						editor: editor
				if selection?
					E ".selection",
						key: "selection"
						className: ("cursor" if selection.end() is selection.start())
						style:
							left: scale * selection.start()
							width: scale * (selection.end() - selection.start())
