md-treasure

This is a pretty simple script. This is meant to replace qb-diving as I used that for the base for the scuba section
There are 14 hidden sunken treasures throughout the map. Each chest will despawn on interaction for 180 seconds so you can't spam it. to install properly there are a few things you need to do

step 1 
``` 
fill out config file. 
 
if you use gksphone turn Config.gks to true. if false it will resort to qb-phone or renewed phone since backwards compatibility

Fill out Config.itemone through 14

this is for a ped that spawns that will give a ping of a location

Fill out Config.Amount 1 through 14

this will require a full number and nothing else. for example 1 

This is meant to help increase RP in city. You can make it require random items from businesses 

fill out Config.langone through 14

that will fill out what you need to get them next.

```

step 2
``` 
add these items to your inventory

['unopenedchest'] 				 		 = {['name'] = 'unopenedchest', 			  	  		['label'] = 'Unopened Chest', 				['weight'] = 200, 		['type'] = 'item', 		['image'] = 'unopenedchest.png', 				['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,   ['combinable'] = nil,   ['description'] = ''},
['oldsilvercoin'] 				 		 = {['name'] = 'oldsilvercoin', 			  	  		['label'] = 'Old Silver Coin', 				['weight'] = 200, 		['type'] = 'item', 		['image'] = 'oldsilvercoin.png', 				['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,   ['combinable'] = nil,   ['description'] = ''},
['oldgoldcoin'] 				 		 = {['name'] = 'oldgoldcoin', 			  	  		['label'] = 'Old Gold Coin', 				['weight'] = 200, 		['type'] = 'item', 		['image'] = 'oldgoldcoin.png', 				['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,   ['combinable'] = nil,   ['description'] = ''},
['waterloggedbook'] 				 		 = {['name'] = 'waterloggedbook', 			  	  		['label'] = 'Water Logged Book', 				['weight'] = 200, 		['type'] = 'item', 		['image'] = 'waterloggedbook.png', 				['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,   ['combinable'] = nil,   ['description'] = ''},
['diving_gear'] 			     = {['name'] = 'diving_gear', 					['label'] = 'Diving Gear', 				['weight'] = 30000, 	['type'] = 'item', 		['image'] = 'diving_gear.png', 			['unique'] = true, 	    ['useable'] = true, 	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'An oxygen tank and a rebreather'},

```

step 3

```
Add images to your inventory
```

Optional

if you use qb-pawnshop put to the bottom of the list and adjust the numbers
```
	[1] = {
        item = "oldsilvercoin",
        price = math.random(800,1500)
    },
    [2] = {
        item = "oldgoldcoin",
        price = math.random(5000,6500)
    },
    [3] = {
        item = "waterloggedbook",
        price = math.random(1000,2000)
    },
```

or qb-traphouse put to the bottom of the list reward = amount of cash
```
	["oldsilvercoin"] = {
        name = "metalscrap",
        wait = 500,
        reward = 3,
    },
    ["oldgoldcoin"] = {
        name = "copper",
        wait = 500,
        reward = 2,
    },
    ["waterloggedbook"] = {
        name = "iron",
        wait = 500,
        reward = 2,
    },
```




