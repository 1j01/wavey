
{E, Component} = require "../helpers.coffee"
ReactDOM = require "react-dom"

keys =
	tab:    9
	enter:  13
	esc:    27
	space:  32
	left:   37
	up:     38
	right:  39
	down:   40

module.exports =
class DropdownMenu extends Component
	# @TODO: allow dragging down from the DropdownButton
	render: ->
		{items, open} = @props
		E ".menu.dropdown-menu",
			role: "menu"
			style: display: ("none" unless open)
			onKeyDown: (e)=>
				elements = Array.from ReactDOM.findDOMNode(@).children
				
				go = (delta)=>
					index = elements.indexOf document.activeElement
					index = Math.max(0, Math.min(elements.length - 1, index + delta))
					elements[index].focus()
				
				switch e.keyCode
					when keys.up
						go -1
					when keys.down
						go +1
					when keys.space, keys.enter
						if document.activeElement in elements
							document.activeElement.click()
					else
						return # don't prevent default
				
				e.preventDefault()
			
			for item, i in items when item? then do (item)=>
				# XXX: shouldn't really need keys here
				if item.type is "separator"
					E "hr", key: "i"
				else
					disabled = item.disabled or ("enabled" of item and not item.enabled)
					E ".menu-item",
						key: item.label
						role: "menuitem"
						disabled: disabled
						tabIndex: 0
						onClick: => item.action() unless disabled
						item.label
	componentDidMount: -> @updateOffset()
	componentDidUpdate: -> @updateOffset()
	updateOffset: ->
		return unless @props.open
		el = ReactDOM.findDOMNode @
		rect = el.getBoundingClientRect()
		dropdown_button_container = el.closest(".dropdown-button-container")
		linked = dropdown_button_container.querySelector(".linked, button")
		if linked?
			linked_rect = linked.getBoundingClientRect()
			if linked_rect.left + rect.width >= document.body.clientWidth
				el.style.left = "#{-rect.width}px"
			else
				el.style.left = "#{-linked_rect.width}px"
		else
			el.style.left = "auto"
