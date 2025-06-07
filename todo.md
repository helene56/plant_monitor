3. add vertical compatible phone layout area
5. add layout for statistik page
6. add layout for vand beholder page
7. add bigger area for touching icons individually on plant stat page
12. use min values from the database to indicate an error in app when the values from the sensors reach below the min values defined in PlantType
13. consider only using database to read/delete and update instead of temp lists used to load data from database
15. setup notify for reading sensor values
    1. use onValue method from flutter blue plus to recieve nofitications if subscribed
    2. set values in plant_stats to the new ones recieved
16. very first time initalizing sensor, it is not ready yet, need to make sure it is