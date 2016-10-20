
# [![Wavey](images/wavey-logotype.png)][app]

[Wavey is the audio editor of the future.][app]


### Features

* Drag and drop audio files or record from a microphone*
* Always saved locally, including persistent undo/redo with the selection state; saves *while* you're recording
* Several themes, including light and dark [elementary OS][] themes via [elementary.css][], and some retro themes
* Fully scalable graphics, from the icons to the waveforms
* Export the document or a selected range as WAV or MP3
* Can work completely offline

*Audio recording quality may or may not match native applications in a given browser.
Record redundantly with another application if it matters to you.

### Future Features

* Note how the bar with beat markings is a track. It would become a metronome when unmuted.
It's a simplification of the concepts over DAWs which traditionally have a separate metronome.
There will still need to be a way to specify the BPM, and
it would also be good to have BPM detection and
variable BPM support (hopefully tying into a general automation system).

* Tracks can be pinned to the top,
which should easy the pain when you have many tracks with audio clips
you want to line up with some main audio track(s).
(This is only partially implemented. Currently pinned tracks don't actually stay at the top when scrolling down.)

* You will be able to "precord" up to five minutes as long as precording has been enabled.

* MIDI is a possibility. It might involve an expanded view to edit the notes, but it would be inline in the track.

* Effects! I'm holding off on adding gain and panning because
I think if the effects UI is good enough, they should be able to simply be effects,
and I don't want to just immitate the status quo UI and end up with something that's "good enough" but not as good as it could be.
They (or just gain) may warrant some shortcutting, such as being added by default to the effects chain,
but they probably shouldn't be separate from it.
After all they *are* effects and you'll want to be able to automate them just the same.

* Plugins

* Desktop apps; app embedding

* Interoperability with Audacity (exporting/importing project files)

* Web Intents or similar, possibly [Ballista](https://github.com/chromium/ballista)

* Accessibility and internationalization


### TODO

* Fix pasting across non-consecutive tracks
* Fix pasting placing the cursor across all tracks after the top track
* Mouse-relative zooming (preferably performant and smoothly animated)
* Storage management (handle running out of storage, handle multiple editors loaded for the same document, and allow data purging)


### Contributing

Contributions and criticism welcome.
[Open up an issue][new issue] to discuss features, problems, or improvements!

This project is built with [CoffeeScript][], [React][], and [ReactScript][].


### License

The MIT License (MIT)

Copyright (c) 2015 Isaiah Odhner

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


[app]: https://audioeditor.ml/
[elementary OS]: https://elementary.io/
[elementary.css]: https://github.com/1j01/elementary.css/
[CoffeeScript]: http://coffeescript.org/
[React]: https://facebook.github.io/react/
[ReactScript]: https://github.com/1j01/react-script
[new issue]: https://github.com/1j01/wavey/issues/new
