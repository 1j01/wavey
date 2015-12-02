
class @DropdownButton extends E.Component
	@instances: []
	
	constructor: ->
		@state =
			menu_open: no
			just_opened_via_mousedown: no
	
	componentDidMount: ->
		DropdownButton.instances.push @
		window.addEventListener "mouseup", @_onmouseup = (e)=>
			setTimeout => # after a possible click event
				@setState just_opened_via_mousedown: no
	
	componentWillUnmount: ->
		DropdownButton.instances.splice DropdownButton.instances.indexOf(@), 1
		window.removeEventListener "mousedown", @_onmousedown
		window.removeEventListener "mouseup", @_onmouseup
	
	componentDidUpdate: ->
		unless @state.menu_open
			window.removeEventListener "mousedown", @_onmousedown
	
	toggleMenu: =>
		{menu_open} = @state
		for b in DropdownButton.instances
			b.setState menu_open: no
		if menu_open
			@setState menu_open: no
		else
			@setState menu_open: yes
			window.removeEventListener "mousedown", @_onmousedown
			window.addEventListener "mousedown", @_onmousedown = (e)=>
				unless closest e.target, ".dropdown-button, .menu-positioner"
					@setState menu_open: no
	
	render: ->
		{menu_open} = @state
		{children, title, mainButton, menu} = @props
		E "span.dropdown-button-container",
			class: ("menu-open" if menu_open)
			E ".menu-positioner",
					style: position: "relative", display: "inline-block"
					if menu_open
						E DropdownMenu,
							items:
								for item in menu when item?
									do (item)=>
										label: item.label
										action: =>
											@setState menu_open: no
											item.action()
			E "span.linked",
				mainButton
				E "button.button.dropdown-button",
					onMouseDown: =>
						unless @state.menu_open
							@setState just_opened_via_mousedown: yes
							@toggleMenu()
					onClick: =>
						@setState just_opened_via_mousedown: no
						@toggleMenu() unless @state.just_opened_via_mousedown
					title: title
					if children?.length then children else E "i.octicon.octicon-chevron-down"