
## Overall architecture

* There is a "Master" that receives keypress notifications from the Atom editor
* There are n "Providers" that register themselves for specific scopes
* The Master farms out "Context" to the matching providers when a key is pressed
* Providers return a ranked set of "Results" which the Master interleaves and displays the AutocompleteView when a timeout occurs (no need for an autocomplete window to flicker on and off as the user is typing away madly)
* The Master will need to be able to issue a new search, causing the Providers to abandon old searches, if a new key comes in
* The searches would be happening and results updating all the time, but the display of the results would only happen when the user took a quarter second's pause.

## Responder Process

The master and providers all run together in a process separate from Atom called the "responder process".  This prevents the responder computation from blocking the main user interaction (typing) in Atom.

Each provider is run as a web worker in the responder process.  A web worker can be terminated immediately at any time.  So the master can send the word typed so far and a context to a provider (web worker) which the provider starts processing.  If the next key is typed quickly in atom the master can terminate the worker immediately and start a new one with the new word (and probably the same context).  So providers must be lightweight and not involve a lot of startup computation.  Pre-computation should be done in advance and provided in the context.

## Background Process

There is a third process that runs constantly in the background aptly named the "background process".  It parses files and does the pre-computation for the providers.  It also has a master and providers.

## Provider

Each provider is an npm module.  It has two special functions exported from the main source file.  One function is called from the master of the background process and does the pre-processing.  The second function is called by the master of the responder process to compute and return the autocomplete options.

The provider module is not aware of the environment it is run in. It does not know it is a web worker. It just knows that it pre-computes data in one function, like parsing files, and uses that data along with the provided partial word and context in the second.  This allows the design of the masters to change and evolve.

The provider also doesn't know it's true lifecycle.  It is written as if it has one task to do and complete.  The abort and restart are transparent. 

## Provider Helper Routines

Each of the two process masters maintain and access data structures for the pre-processed data.  They provide API calls for the providers to call to access the data.  The masters are responsible for giving each provider an isolated view into the data.  The format of the data passed is in a pre-determined fixed format but the master is allowed to change how the data is stored, again so the masters can evolve.

