Config = {}
Config.Locale = 'en' -- Default is 'en' --> You can change/add in locale.lua

-----------
---UTILS---
-----------
Config.Mode = 'debug' -- active, test, debug
Config.checkForUpdates = true -- Recommended to leave on 'true'
Config.Webhook = "https://discord.com/api/webhooks/1219808274761912370/o_tW_tU3oUHTyvHJVEa3qRvnuabYs3TNH3VoswJPqKI6VKS2EfHC2LyQCoXcwQ9oQiEC"

---------------
---SETTINGS---
--------------
Config.Weapons = {'weapon_pistol', 'weapon_assaultrifle'} -- Example weapons, add more as needed
Config.PoliceJobs = {'police', 'sheriff'} -- Jobs that will be known as police

-------------
---ROBBERY---
-------------
Config.Time = 15 -- Time in minutes for the robbery
Config.Reward = 250000 -- Default reward amount, adjust as needed
Config.StartLocation = {x = 813.46, y = -2982.56, z = 6.02} -- Start location for the robbery

-------------------------
---CONTAINER LOCATIONS---
-------------------------
Config.Containers = {
    {x = 845.24, y = -2990.91, z = 5.9},
    {x = 896.39, y = -2992.58, z = 5.9},
    {x = 896.47, y = -2971.25, z = 5.9},
    {x = 923.4, y = -2973.84, z = 5.9},
    {x = 924.48, y = -2992.27, z = 5.9},
    {x = 896.49, y = -3026.34, z = 5.9},
    {x = 896.44, y = -3039.33, z = 5.9},
    {x = 896.48, y = -3077.54, z = 5.9},
    {x = 896.67, y = -3096.15, z = 5.9},
    {x = 910.49, y = -3098.88, z = 5.9},
    {x = 909.34, y = -3091.99, z = 5.9},
    {x = 924.45, y = -3080.2, z = 5.9},
    {x = 923.57, y = -3096.11, z = 5.9},
    {x = 938.28, y = -3093.42, z = 5.9},
    {x = 951.42, y = -3080.22, z = 5.9},

    -- Add more containers as needed
}
