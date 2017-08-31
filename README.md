
# [![Wavey](images/wavey-logotype.png)][app]

[Wavey][app] is a simple web-based digital audio workstation (DAW), currently in alpha.

### Features

* Drag and drop audio files or record from a microphone\* (\*\*)
* Always saved locally, including persistent undo/redo with the selection state; saves *while* you're recording\*\*
* Several themes, including light and dark [elementary OS][] themes via [elementary.css][], and some retro themes
* Fully scalable graphics, from the icons to the waveforms
* Export the document or a selected range as WAV or MP3
* Can work completely offline, with [sw-precache][]

\*Audio recording quality may or may not match native applications in a given browser.
Record redundantly with another application if it matters to you.

\*\*There's a bug right now where chunks are lost when recording!
Chunks are appended blindly and the data written to the timeline will fall behind the position indicator.
If you try to record something in time with something already recorded,
you might not notice until you listen back but it'll get shifted over in time and end up earlier,
and there will be skips in the audio.


### Future Features

* Note how the bar with beat markings is a track. It would become a metronome when unmuted.
It's a simplification of the concepts over DAWs which traditionally have a separate metronome.
There will still need to be a way to specify the BPM, and
it would also be good to have BPM detection and
variable BPM support (hopefully tying into a general automation system).
One idea I've had is, you could keep the beat with a foot pedal or something,
recorded along with a track.

* Tracks can be pinned to the top,
which should easy the pain when you have many tracks with audio clips
you want to line up with some main audio track(s).
(This partially implemented, but currently pinned tracks don't actually stay at the top when scrolling down.)

* You will be able to "precord" up to five minutes as long as precording has been enabled.
[Precorder][] is a separate project to let you do a similar thing in the background.

* Projects should be able to contain separate, distinct timelines;
some DAWs have "takes", maybe something like that is what I want.
Ableton Live does something fairly reasonable.

* MIDI. It would probably involve an expanded view to edit the notes, but inline in the track.
(I've made a basic (non-expanded) notes view component but haven't made a way to actually create it in the editor.
No way to create or import MIDI data.)

* Effects! I'm holding off on adding gain and panning because
I think if the effects UI is good enough, they should be able to simply be effects,
and I don't want to just immitate the status quo UI and end up with something that's "good enough" but not as good as it could be.
Gain/panning may warrant special treatment such as being added by default to the effects chain,
but they probably shouldn't be separate from it.
After all you'll want to be able to automate them just the same.

* Plugins
(e.g. instrument interfaces like
[tri-chromatic-keyboard](https://github.com/1j01/tri-chromatic-keyboard) or
[guitar](https://github.com/1j01/guitar),
effects,
synthesizers (voices),
algorithmic synthesis like [HTML5 Bytebeat](http://greggman.com/downloads/examples/html5bytebeat/html5bytebeat.html),
themes,
extra file formats)

* Desktop app, ideally native

* Interoperability with Audacity? (exporting/importing project files)

* Whatever replaces Web Intents, probably the [Web Share API](https://github.com/WICG/web-share) and [Web Share Target API](https://github.com/WICG/web-share-target)

* Internationalization


### TODO

* Fix losing chunks when recording
* Fix pasting across non-consecutive tracks
* Mouse-relative zooming (preferably performant and smoothly animated)
* Storage management (handle running out of storage, handle multiple editors loaded for the same document, allow data purging, estimate max recording time)
* Improve accessibility


### Contributing

Contributions and criticism welcome.
[Open up an issue][new issue] to discuss features, problems, or improvements!

This project is built with [CoffeeScript][], [React][], and [ReactScript][].

[Fork and clone the repository](https://guides.github.com/activities/forking/) and then
with [Node.js](https://nodejs.org/en/),
open up a command line and enter
`npm install` and `npm run dev`


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
[Precorder]: https://github.com/1j01/precorder/
[sw-precache]: https://github.com/GoogleChrome/sw-precache
[CoffeeScript]: http://coffeescript.org/
[React]: https://facebook.github.io/react/
[ReactScript]: https://github.com/1j01/react-script
[new issue]: https://github.com/1j01/wavey/issues/new
