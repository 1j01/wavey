
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
				return unless e.button is 0
				el = closest e.target, ".track-content"
				unless el
					unless closest e.target, ".track-controls"
						e.preventDefault()
						@setState selection: null
					return
				e.preventDefault()
				
				time_at = (e)=>
					rect = el.getBoundingClientRect()
					(e.clientX - rect.left) / scale
				
				t = time_at e
				@setState selection: new Selection t
				
				window.addEventListener "mousemove", onMouseMove = (e)=>
					if @state.selection
						@setState selection: Selection.drag @state.selection, to: time_at e
						e.preventDefault()
				
				window.addEventListener "mouseup", onMouseUp = (e)=>
					window.removeEventListener "mouseup", onMouseUp
					window.removeEventListener "mousemove", onMouseMove
			E BeatTrack, key: 1
			E AudioTrack, key: 2, selection: @state.selection
			E AudioTrack, key: 3, selection: @state.selection
