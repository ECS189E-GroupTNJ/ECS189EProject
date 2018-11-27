# Sprint Meeting Log

## Meeting 1

### Past Progress
* -

### Current Issues
* -

### Coming Tasks
* UI
	* Design UI for previously discussed view controllers
	* Possible addition of Settings view controller
		* To be discussed in later meetings
	* Integration of open source UI libraries for better aesthetics
	* Complete the implementation of necessary interfaces by next week
		* Text fields for user information, buttons for triggering events, etc.
	* Task Owner: Noshin

* Authorization (Spotify)
	* For SpotifyUserModel, implement Spotify login
		* take in Spotify username and password to receive authentication token
	* Take in account of all authorization scopes for the purpose of the app
	* Task Owner: Jason

* Track Identification
	* Read in the currently playing track
	* Possible extension of displaying song information
		* show album cover, artist name, title, etc.
	* Task Owner: Tony

* Addtion to Playlist
	* Add the playing track to a playlist
	* By default, add to a playlist of set name
		* possible extension to select a playlist as a setting
	* Task Owner: Tony
    

## Meeting 2

### Past Progress
* UI 
	* Initial screen complete
	* Song addition screen complete
	
* Authorization
	* Registered developer app for spotify
	* Receive access tokens
	* Able to connect to installed Spotify app
	
* Track Identification
	* Able to retrieve current track info (given authentication setup)
	* Retreive album cover, artist name, track title for possible UI usage

* Addition to Playlist
	* Default playlist created if not selected
	* Create playlist if necessary
	* Update the user's list of playlists
	* Add the track to playlist given track ID
	* Implement Spotify Web API calls

### Current Issues
* Framework/Library to be used for Challenge not decided
	* To be discussed again in the next meeting

### Coming Tasks
* Research possible methods of detecting near by app users

* Implement View Controllers (connect UI and model)
* UI for PlaylistTableView
* Professor's Challenge
* Retrieve playlist image for display

* Tasks to be distributed on Tuesday (Next meeting)
