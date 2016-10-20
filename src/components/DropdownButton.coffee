
{E, Component} = require "../helpers.coffee"
React = require "react"
ReactDOM = require "react-dom"
DropdownMenu = require "./DropdownMenu.coffee"

module.exports =
class DropdownButton extends Component
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
		
		window.addEventListener "keydown", @_onkeydown = (e)=>
			if e.keyCode is 27 # Esc
				@setState menu_open: no
				e.preventDefault()
	
	componentWillUnmount: ->
		DropdownButton.instances.splice DropdownButton.instances.indexOf(@), 1
		window.removeEventListener "mousedown", @_onmousedown
		window.removeEventListener "mouseup", @_onmouseup
		window.removeEventListener "keydown", @_onkeydown
	
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
			@setState menu_open: yes, =>
				unless @state.just_opened_via_mousedown
					ReactDOM.findDOMNode(@).querySelector(".menu-item").focus()
			window.removeEventListener "mousedown", @_onmousedown
			window.addEventListener "mousedown", @_onmousedown = (e)=>
				unless e.target.closest(".dropdown-button, .menu-positioner")
					@setState menu_open: no
	
	render: ->
		{menu_open} = @state
		{children, title, tabIndex, mainButton, menu} = @props
		E "span.dropdown-button-container",
			class: ("menu-open" if menu_open)
			aria: expanded: menu_open
			E "span.linked",
				mainButton
				E "button.button.dropdown-button",
					aria: haspopup: yes
					onMouseDown: =>
						unless @state.menu_open
							@setState just_opened_via_mousedown: yes
							@toggleMenu()
					onClick: =>
						@setState just_opened_via_mousedown: no
						@toggleMenu() unless @state.just_opened_via_mousedown
					title: title
					tabIndex: tabIndex
					if children?.length or React.isValidElement(children) then children else E "i.octicon.octicon-chevron-down"
			E ".menu-positioner",
					E DropdownMenu,
						open: menu_open
						items:
							for item in menu when item?
								do (item)=>
									if item.type is "separator"
										item
									else
										Object.assign {}, item,
											action: =>
												@setState menu_open: no
												item.action()