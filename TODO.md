# LÖVE3D Roadmap

## VENI ☆ VIDI ☆ VICI

### Always
* Improve assets
* Add maps

### Next

* Preferences system (just some json, really)
* Make server terrain-aware
* Cannon keyhole
* Improve IRC Chat
* Teams
* HUD

### Later

* Make server authoritative
* Culling (skip drawing for chunks and objects that are not visible)
* Fix terrain normals
* Fix shading
* Add light objects
* Shadows
* Single Player Mode (if server not available)
* Controller keyboards
	* T9
	* qwerty
	* flower
* Accel / Decel
* Bounding Box Collision
	* Ray-Triangle (the first triangle is just 3 rays!)
* Improve map loader
* IQM support (now that we can read structs nicely!)

### Eventually

* Physically Based Rendering
* Physics
	* Maybe we should look into Bullet
* PSO2 chat
	* what parts, specifically?
* Terrain generator needs some life
	* City generator!
	* Grass
	* Fauna
		* Fuck yeah, wild animal NPCs!
	* Floura
* NPCs
	* AI
* Quadtrees
* Octrees
* Terrain LOD
* Camera types
	* Rigid
	* Mouse
	* Free
	* Cinematic
* Two-bone IK
* Clamp nameplates to viewport
* Improve Character / Complex Model Support
* Area of Influence
	* Chat
	* Fog of War
	* Collision Detection


### ¡WE DID IT!

1. Bounding boxes (iqe)
1. Save name between sessions
1. Shooting
1. Fix name tags for off screen players
1. Collision (Circle-Circle)
1. IRC Chat
1. Share code between client and server
1. Gamepad support
1. Bone Interpolation
1. Rewrite server system
	1. map out packets
	1. implement a way to send/receive them
	1. actually make the game use that shit
1. Separate spawn points for players
1. Re-implement the things we killed when rewriting the networking
1. Mouse control
1. Minimap
