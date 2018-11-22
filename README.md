# ECS189E Project

## Third Party Library
* Spotify iOS SDK

## Server Support
* SpotifyServer

## View Controllers

### LoginViewController
* initial view controller
* takes Spotify account
* move to VoiceControlViewController after login is complete

### VoiceControlViewController
* upon specific voice command, switch to IdentificationViewController
* start with a capture button, experiment with voice controls if time allows

### IdentificationViewController
* After identifying the music / adding to playlist, switch back to VoiceControlViewController


## Models
* SpotifyModel: handle Spotify related tasks: authentication/playlist modification

## Test Planning
* Classmates/friends survey
	* How easy is the app to use?
	* How comfortable is adding the track to the playlist?
	* What would be some convenient features/configurations for this app?
	* How long does each task (requring API calls) take?

![screens](https://github.com/ECS189E-GroupTNJ/ECS189EProject/raw/master/screens.png)

## Meeting Schedule
* Monday 10 am
* Friday 11 am
* Tuesday 12 pm (Sprint)

## Trello
* https://trello.com/b/z4m1ryer/ecs189e

## Challenge
* When adding a song, add the song to playlist of everyone in the car
* Can assume that everyone in the car is already running the app

## Team Members
* Tony Woo (Github: tonyswoo)
* Noshin Kamal (Github: noshin-k)
* Jason Bhan (Github: jhbhan)
