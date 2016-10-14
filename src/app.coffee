
localforage = require "localforage"
ReactDOM = require "react-dom"
{E} = require "./helpers.coffee"
{AudioEditor} = require "./components/AudioEditor.coffee"

if location.protocol is "http:" and location.host.match /editor|app/
	location.protocol = "https:"

window.actx = new (
	window.AudioContext ?
	window.webkitAudioContext ?
	window.mozAudioContext ?
	window.oAudioContext ?
	window.msAudioContext
)

themes = require "../themes.json"

theme_link = document.createElement "link"
theme_link.rel = "stylesheet"
theme_link.type = "text/css"
document.head.appendChild theme_link

set_theme = (theme)->
	localforage.setItem "theme", theme
	# XXX: absolute URL
	# FIXME: URL resolution in NW.js app
	theme_link.href = "/build/themes/#{theme}"

# TODO: load theme faster/earlier somehow?
localforage.getItem "theme", (err, theme)->
	set_theme theme ? "elementary.css"

container = document.createElement("div")
container.id = "app"
document.body.appendChild(container)

window.render = ->
	document_id = (location.hash.match(/document=([\w\-./]*)/) ? [0, "default"])[1]
	ReactDOM.render (E AudioEditor, {key: document_id, document_id, themes, set_theme}), container

window.addEventListener "hashchange", render
render()
