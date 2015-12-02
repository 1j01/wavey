
class @InfoBar extends E.Component
	
	@state:
		message: null
		message_class: null
		visible: no
	
	@setState: (state)=>
		for k, v of state
			@state[k] = v
		render()
	
	@error: (message)=>
		@setState {message, message_class: "error", visible: yes}
	
	@warn: (message)=>
		@setState {message, message_class: "warn", visible: yes}
	
	@info: (message)=>
		@setState {message, message_class: "info", visible: yes}
	
	@question: (message)=>
		@setState {message, message_class: "question", visible: yes}
		# @TODO: buttons
	
	@hide: (message)=>
		if message?
			if @state.message is message
				@setState visible: no
		else
			@setState visible: no
	
	render: ->
		{message, message_class, visible} = InfoBar.state
		# @TODO: remove Gtk-isms
		E "GtkInfoBar.warning",
			classes: [message_class, if visible then "visible"]
			E "GtkLabel", message
			E "button.button",
				disabled: not visible
				onClick: => InfoBar.setState visible: no
				E "GtkLabel", "Dismiss"

###
class @InfoBar extends E.Component
	
	constructor: ->
		@state =
			message: null
			message_class: null
			visible: no
	
	error: (message)=>
		@setState {message, message_class: "error", visible: yes}
	
	warn: (message)=>
		@setState {message, message_class: "warn", visible: yes}
	
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
		# @TODO: remove Gtk-isms
		# @TODO: animate appearing/disappearing
		E "GtkInfoBar.warning",
			classes: [message_class, if visible then "visible"]
			E "GtkLabel", @state.alert_message
			E "button.button",
				disabled: not visible
				onClick: => @setState alert_message: null
				E "GtkLabel", "Dismiss"
###
