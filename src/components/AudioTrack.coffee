
class @AudioTrack extends E.Component
	render: ->
		{track, selection, position, playing, editor} = @props
		{clips, muted, pinned} = track
		
		E Track, {track, editor},
			E "div",
				style:
					position: "relative"
					height: 80 # = canvas height
					boxSizing: "content-box"
				onDragOver: (e)=>
					e.preventDefault()
				onDrop: (e)=>
					# @FIXME: WET, @TODO: DRY, this was copy/pasted from Tracks.coffee
					el = closest e.target, ".track-content"
					unless el
						unless closest e.target, ".track-controls"
							e.preventDefault()
							@setState selection: null
						return
					e.preventDefault()
					
					time_at = (e)->
						rect = el.getBoundingClientRect()
						(e.clientX - rect.left) / scale
					
					e.preventDefault()
					# @TODO: add multiple files in sequence, not on top of each other
					for file in e.dataTransfer.files
						editor.add_clip file, track.id, time_at e
				for clip in clips
					E AudioClip,
						key: clip.id
						id: clip.id
						data: AudioClip.audio_buffers_by_clip_id[clip.id]
						editor: editor
						style:
							position: "absolute"
							left: clip.time * scale
				if selection?
					E ".selection",
						key: "selection"
						className: ("cursor" if selection.end() is selection.start())
						style:
							left: scale * selection.start()
							width: scale * (selection.end() - selection.start())
				if position?
					E ".position",
						ref: (@position_indicator)=>
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
