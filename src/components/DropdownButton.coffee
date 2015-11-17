
class @DropdownButton extends E.Component
	@instances: []
	
	constructor: ->
		@state = menu_open: no
	
	componentDidMount: ->
		DropdownButton.instances.push @
	
	componentWillUnmount: ->
		DropdownButton.instances.splice DropdownButton.instances.indexOf(@), 1
	
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
								for item in menu
									do (item)=>
										label: item.label
										action: =>
											@setState menu_open: no
											item.action()
			E "span.linked",
				mainButton
				E "button.button.dropdown-button",
					# @TODO: have these buttons open on mousedown / touchstart
					onClick: =>
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
					title: title
					if children?.length then children else E "i.octicon.octicon-chevron-down"
	
	componentDidUpdate: ->
		unless @state.menu_open
			window.removeEventListener "mousedown", @_onmousedown