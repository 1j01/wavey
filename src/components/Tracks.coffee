
class @Tracks extends E.Component
	constructor: ->
		@state = selection: null
	render: ->
		{tracks} = @props
		E ".tracks",
			onMouseDown: (e)=>
				return unless e.button is 0
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
				
				tracks_el = closest e.target, ".tracks"
				track_index_at = (e)->
					track_index = -1
					for track_el in tracks_el.children
						rect = track_el.getBoundingClientRect()
						if e.clientY > rect.bottom
							track_index += 1
					track_index
				
				t = time_at e
				ti = track_index_at e
				@setState selection: new Selection t, t, ti, ti
				
				window.addEventListener "mousemove", onMouseMove = (e)=>
					if @state.selection
						@setState selection: Selection.drag @state.selection,
							to: time_at e
							toTrackIndex: track_index_at e
						e.preventDefault()
				
				window.addEventListener "mouseup", onMouseUp = (e)=>
					window.removeEventListener "mouseup", onMouseUp
					window.removeEventListener "mousemove", onMouseMove
			E BeatTrack, key: "beat-track"
			for track, ti in tracks
				E AudioTrack,
					key: ti
					track: track
					selection: (@state.selection if @state.selection?.containsTrack ti)
