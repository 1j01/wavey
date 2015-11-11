
class @Tracks extends E.Component
	constructor: ->
		@state = selection: null
	render: ->
		{tracks, position, playing, seek} = @props
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
				
				mouse_moved = no
				#mouse_moved_from = e
				mouse_move_from_clientX = e.clientX
				window.addEventListener "mousemove", onMouseMove = (e)=>
					#dx = e.clientX - mouse_moved_from.clientX
					#dy = e.clientY - mouse_moved_from.clientY
					#if Math.sqrt(dx*dx + dy*dy) > 5
					#console.log e.clientX, mouse_moved_from.clientX
					#if Math.abs(dx) > 100
					if Math.abs(e.clientX - mouse_move_from_clientX) > 5
						mouse_moved = yes
					if mouse_moved
						if @state.selection
							@setState selection: Selection.drag @state.selection,
								to: time_at e
								toTrackIndex: track_index_at e
							e.preventDefault()
				
				window.addEventListener "mouseup", onMouseUp = (e)=>
					window.removeEventListener "mouseup", onMouseUp
					window.removeEventListener "mousemove", onMouseMove
					unless mouse_moved
						@props.seek t
						@setState selection: null
			
			E BeatTrack, key: "beat-track"
			for track, ti in tracks
				E AudioTrack, {
					key: ti
					track, position, playing
					selection: (@state.selection if @state.selection?.containsTrack ti)
				}
