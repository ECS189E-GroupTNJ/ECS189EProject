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
* change to capture button if voice doesn’t work

### IdentificationViewController
* After identifying the music / adding to playlist, switch back to VoiceControlViewController


## Models
* MusicRecognitionModel: 
* SpotifyModel: handle Spotify related tasks: authentication/playlist modification/music 
* VoiceControlModel: parse/handle voice commands

## Test Planning
* Classmates/friends survey
	* How easy is the app to use?
	* How well does the voice recognition work?
	* How well does the music recognition work?
* Quantitative data
	* How many seconds does the music recognition take?
	* Success rate of recognizing voice commands

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