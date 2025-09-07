# DK2ModManager
### Written by Fluffy, Made in Godot
### Fueled by Hopes and Dreams, and Coffee
<img width="1707" height="966" alt="DK2ModManager" src="https://github.com/user-attachments/assets/504affa8-1955-4fc5-8f8a-2c455f5eccc1" />

## Current Supported Platforms are Windows and Linux currently sorry Mac Users

# What can't it do
- It can't handle Workshop Dependencies for you or even warn you about it.  
It's not that I don't want to do that, It's just a very difficult feature to implement and currently I haven't found a Good method to do so.

- It will not warn you of Compatibility problems between Mods.  
I would like to implement this in the future but it will require some complicated crawling of the Mods Files and storing that to match against.
This might also significantly increase the Memory cost of the Application or even Slow down it's features.

- Make you better at the Game.  
Sorry, I can't do that  

# What can it Do then?
- Save and Load Modlists via my own designed XML files.  
These can be shared between friends although it doesn't handle grabbing the missing mods for you.
But it will show a List of Mods missing and buttons on the Workshop Mods to take you to the Page so you can download it.

- Organise the Modlist shifting the Order around using the `Move Up` and `Move Down`.
I wanted to implement a Drag and Drop sort of System but at the moment It was very complicated to setup correctly with the current state of the Project.

- Launch the Game with and Without Mods via the Launch buttons.
Currently the method behind launching without mods if to clear your `Options.xml` of Mods then launch, so if you don't save the enabled list before changing it or closing the program it will be lost keep that in mind.

### If you have Issues message me on Discord or Ping me in the Doorkickers Discord.
### Alternatively if you have a Github Account create an Issue on this Repo.

### Thanks for your Time, Happy DoorKicking - Fluffy
