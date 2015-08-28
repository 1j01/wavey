
class @AudioTrack extends E.Component
	constructor: ->
		@state = selection: null
	
	render: ->
		
		scale = 90
		# time_at = (e)=>
		# 	el = React.findDOMNode @refs.content
		# 	rect = el.getBoundingClientRect()
		# 	(e.clientX - rect.left) / scale
		at_time = (t)->
			t * scale
		
		# E ".audio-track",
		E Track,
			E ".audio-clips",
				ref: "content"
				style: position: "relative", height: 80
				onMouseDown: (e)=>
					e.preventDefault()
					el = React.findDOMNode @refs.content
					time_at = (e)=>
						rect = el.getBoundingClientRect()
						(e.clientX - rect.left) / scale
					
					t = time_at e
					@setState selection: [t, t]
					
					window.addEventListener "mousemove", onMouseMove = (e)=>
						if @state.selection
							t = time_at e
							@setState selection: [t, @state.selection[1]]
							e.preventDefault()
					
					window.addEventListener "mouseup", onMouseUp = (e)=>
						window.removeEventListener "mouseup", onMouseUp
						window.removeEventListener "mousemove", onMouseMove
				
				# onMouseMove: (e)=>
				# 	if @state.selection
				# 		t = time_at e
				# 		@setState selection: {start: @state.selection.start, end: t}
				
				E AudioClip, style: position: "absolute", left: 0
				if @state.selection
					if @state.selection[0] < @state.selection[1]
						[start, end] = @state.selection
					else
						[end, start] = @state.selection
					start = Math.max(0, start)
					end = Math.max(0, end)
					E ".selection",
						style:
							position: "absolute"
							left: at_time start
							width: (at_time end) - (at_time start)
							height: "100%"
