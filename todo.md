3. add vertical compatible phone layout area
5. add layout for statistik page
6. add layout for vand beholder page
7. add bigger area for touching icons individually on plant stat page
12. use min values from the database to indicate an error in app when the values from the sensors reach below the min values defined in PlantType
13. consider only using database to read/delete and update instead of temp lists used to load data from database
14. add bluetooth to project
    1. connect to sensor if availible
        1. in create a plant dialog -> show availible sensors to pair
    2. sensor send data on initial pairing -> when created
    3. when update button clicked and still in range of bluetooth -> send updated data if update is there
    4. might make 3. unnesecary: autoconnect to already once established connections (saved in db)
    5. when first time adding a device connect once (so not autoconnect)