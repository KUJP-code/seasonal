[Visual Schema Link](https://lucid.app/lucidchart/582c392f-7113-4fb7-9a93-8697af8fa27d/edit?invitationId=inv_4ec19f91-a432-4b99-a0d2-09d50b682b5f&page=0_0#)

Can't have many to many for options and time slots, but have some way of copying/pre-filling commonly used ones for UX

Need to be able to add children to a parent by entering SSID and birthday
    - EZ enough, just have a #where query by birthday and SSID that pushes the kid to the parent's children list if one is found
    - kinda a security problem though? SSID and birthday are ez to guess if family friend etc.
    - Though that's mitigated by each kid only having a single parent, just check if they already have a parent and throw an error/don't change if they do

This will not be an a table, but need to be able to calculate total costs per event/child/slot/parent etc. with a scope or more likely class method on a model

Registering for a slot gives you the ability to register for its options. This should probably update through a turboframe on the main event page so they don't have to click back and forward through a bunch of screens.
    - Right now I'm thinking just render the time slot#show view in the frame, but we'll see when I get to it


When you get around to the bits which use callbacks again, remember after_commit on: [actions] is better than after_create for eg., to deal better with rollbacks