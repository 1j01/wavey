
class @AudioTrack extends E.Component
	
	at_time = (t)-> t * scale
	
	render: ->
		{track, selection, position, playing} = @props
		
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
				if selection?
					E ".selection",
						key: "selection"
						style:
							left: (at_time selection.start())
							width: (at_time selection.end()) - (at_time selection.start())
				if position?
					E ".position",
						ref: (c)=> @position_indicator = c
						key: "position"
						style:
							left: (at_time position)
	
	animate: ->
		@animation = requestAnimationFrame => @animate()
		if @props.playing
			if @position_indicator
				@position_indicator.getDOMNode().style.left =
					"#{(at_time actx.currentTime - @last_position_update_time)}px"
	
	componentDidUpdate: (last_props)->
		if @props.position isnt last_props.position
			@last_position_update_time = actx.currentTime - @props.position
	
	componentDidMount: ->
		@animate()
	
	componentWillUnmount: ->
		cancelAnimationFrame @animation
