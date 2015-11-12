
class @AudioTrack extends E.Component
	render: ->
		{track, selection, position, playing, mute_track, unmute_track, pin_track, unpin_track, remove_track, track_index} = @props
		{clips, muted, pinned} = track
		
		E ".track.audio-track",
			classes: {muted, pinned}
			E TrackControls, {muted, pinned, mute_track, unmute_track, pin_track, unpin_track, remove_track, track_index}
			E ".track-content",
				ref: "content"
				style:
					position: "relative"
					height: 80 # = canvas height
					boxSizing: "content-box"
				for clip in clips
					E AudioClip,
						key: clip.id
						id: clip.id
						data: audio_buffer_for_clip clip.id
						style:
							position: "absolute"
							left: clip.time * scale
				if selection?
					E ".selection",
						key: "selection"
						style:
							left: scale * selection.start()
							width: scale * (selection.end() - selection.start())
				if position?
					E ".position",
						ref: (c)=> @position_indicator = c
						key: "position"
						style:
							left: scale * position
	
	animate: ->
		@animation_frame = requestAnimationFrame => @animate()
		if @props.playing
			if @position_indicator
				position = @props.position + actx.currentTime - @props.position_time
				@position_indicator.getDOMNode().style.left = "#{scale * position}px"
	
	componentDidMount: ->
		@animate()
	
	componentWillUnmount: ->
		cancelAnimationFrame @animation_frame
