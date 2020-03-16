
{E, Component} = require "../helpers.coffee"

module.exports =
class InfoBar extends Component
	
	@state:
		message: null
		message_class: null
		buttons: null
		visible: no
	
	@setState: (state)=>
		prev_state = {}
		for k, v of @state
			prev_state[k] = v
		
		for k, v of state
			@state[k] = v
		
		return if (
			@state.message is prev_state.message and
			@state.message_class is prev_state.message_class and
			@state.visible is prev_state.visible
		)
		
		setTimeout =>
			render()
			if @state.visible and not prev_state.visible
				document.querySelector(".info-bar button").focus()
		, 50
	
	@error: (message, buttons)=>
		@setState {message, buttons, message_class: "error", visible: yes}
	
	@warn: (message, buttons)=>
		@setState {message, buttons, message_class: "warning", visible: yes}
	
	@info: (message, buttons)=>
		@setState {message, buttons, message_class: "info", visible: yes}
	
	@question: (message, buttons)=>
		@setState {message, buttons, message_class: "question", visible: yes}
	
	@hide: (message)=>
		if message?
			if @state.message is message
				@setState visible: no
		else
			@setState visible: no
	
	render: ->
		{message, message_class, visible, buttons} = InfoBar.state
		buttons ?= [
			label: "Dismiss"
			action: ->
		]
		E ".info-bar",
			classes: [message_class, if visible then "visible"]
			role: "alertdialogue" # @FIXME: message can be read multiple times, sometimes repeatedly
			aria: hidden: not visible
			E "gtklabel", key: "message", message
			for button, i in buttons
				E "button.button",
					key: i
					disabled: not visible
					aria: hidden: not visible
					tabIndex: (-1 unless visible)
					onClick: =>
						InfoBar.setState visible: no
						button.action()
					E "gtklabel", button.label
	
	# shouldComponentUpdate: (next_props, next_state)->
	# 	next_state.message isnt @state.message or
	# 	next_state.message_class isnt @state.message_class or
	# 	next_state.visible isnt @state.visible or
	# 	next_state.buttons isnt @state.buttons # (?)

###
module.exports =
class InfoBar extends Component
	
	constructor: ->
		@state =
			message: null
			message_class: null
			visible: no
	
	error: (message)=>
		@setState {message, message_class: "error", visible: yes}
	
	warn: (message)=>
		@setState {message, message_class: "warning", visible: yes}
	
	info: (message)=>
		@setState {message, message_class: "info", visible: yes}
	
	question: (message)=>
		@setState {message, message_class: "question", visible: yes}
		# @TODO: buttons
	
	hide: (message)=>
		if message?
			if @state.message is message
				@setState visible: no
		else
			@setState visible: no
	
	render: ->
		{message, message_class, visible} = @state
		# @TODO: animate appearing/disappearing
		E ".info-bar",
			classes: [message_class, if visible then "visible"]
			E "gtklabel", @state.alert_message
			E "button.button",
				disabled: not visible
				onClick: => @setState alert_message: null
				E "gtklabel", "Dismiss"
###
