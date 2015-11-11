
class @DropdownMenu extends E.Component
	render: ->
		{items} = @props
		E ".menu.dropdown-menu",
			for item in items
				E ".menu-item",
					key: item.label
					onClick: item.action
					item.label
	componentDidMount: -> @updateOffset()
	componentDidUpdate: -> @updateOffset()
	updateOffset: ->
		# @FIXME alternates offset during playback
		el = React.findDOMNode @
		rect = el.getBoundingClientRect()
		if rect.right >= document.body.clientWidth
			linked = el.parentElement.nextSibling
			if linked?.classList.contains "linked"
				linked_rect = linked.getBoundingClientRect()
				el.style.left = "#{linked_rect.width - rect.width}px"
			else
				el.style.left = "auto"
		else
			el.style.left = ""
