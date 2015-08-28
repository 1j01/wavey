
closest = (elem, selector)->
	matches = elem.matches ? elem.webkitMatchesSelector ? elem.mozMatchesSelector ? elem.msMatchesSelector
	while elem
		return elem if matches.call elem, selector
		elem = elem.parentElement
	no

class @Tracks extends E.Component
	constructor: ->
		@state = selection: null
	render: ->
		E ".tracks",
			onMouseDown: (e)=>
				el = closest e.target, ".track-content"
				return unless el
				return unless e.button is 0
				e.preventDefault()
				
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
			E BeatTrack, key: 1
			E AudioTrack, key: 2, selection: @state.selection
			E AudioTrack, key: 3, selection: @state.selection
