wigflip is a casual game built with Apple’s SpriteKit (https://developer.apple.com/spritekit/ ).

This game was written for iOS 14 and also runs on macOS.

I am not a professional game programmer, but thought I’d share this for anyone using SpriteKit. This sample code shows how I:
	* set up a multiplatform game with some AppKit and UIKit code where needed
	* use emitters
	* integrate Game Center scores and achievments
	* localize the game (French and Japanese)
	* set up minor keyboard and game controller compatibility
	* create my color palettes via hex colors that are translated to NSColor and UIColor as needed
	* save game state via a simple JSON file

Gameplay
The concept for this game is simple: birds move into the treehouse and throw out random objects. If the object happens to be an egg, capturing it will hatch another bird. The treehouse grows to accomodate up to 12 birds. As seasons change, birds migrate away and others move in (Each type of bird represents an achievement).

More details are available in the comments.

