
class @AudioTrack extends E.Component
	render: ->
		{track, selection} = @props
		at_time = (t)-> t * scale
		E ".track.audio-track",
			E TrackControls
			E ".track-content",
				ref: "content"
				style: position: "relative", height: 80, boxSizing: "content-box" # 80 = canvas height
				for clip in track.clips
					E AudioClip,
						key: clip.id
						id: clip.id
						data: audio_buffer_for_clip clip.id
						style:
							position: "absolute"
							left: clip.time * scale
				if selection
					E ".selection",
						key: "selection"
						style:
							position: "absolute"
							left: (at_time selection.start())
							top: 0
							width: (at_time selection.end()) - (at_time selection.start())
							height: "100%"
