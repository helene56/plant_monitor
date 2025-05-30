2. make plant cards scrollable
3. add vertical compatible phone layout area
5. add layout for statistik page
6. add layout for vand beholder page
7. add bigger area for touching icons individually on plant stat page
8. add sqlite functionality - save plant data
    3. add method to delete plant from database
    4. use data stored in database to populate plant page
9. dont add plant card if another with same name exists - give warning at add
10. organize code for main, add_plant. The different functions are not so organized.
11. add table in DB for:
    1. type and its specific data, whenever a new plant is made, everything except name and id in Plant should be filled out from the specific type
    2. sensor class data, real time data from plant sensor values
12. use min values from the database to indicate an error in app when the values from the sensors reach below the min values defined in PlantType