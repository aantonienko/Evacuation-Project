# Evacuation-Project

This projects investigates a possible correlation between median income and places where evacuation rates spiked the most significantly in response to Hurricane Dorian, which passed by the east coast of the state on September 4, 2019.
All data needed to run the script and the script itself is included in the zipfile.

Datasets:
- “Nodes”, a .rds where each row was a county subdivision and each column was some kind of demographic, economic, or social information about that row. Median income was missing in some cases, notably in Cape Sable.
- “Edges”, a .rds where each row is a path between two Florida municipalities, by geoid, at a specific date and time block. It includes an “evacuation” column, the number of Facebook users at the indicated time who were leaving on that path (positive number) or staying (negative number) compared to that path’s normal level of movement. I filtered this dataset to include only rows coming from Florida.
- "County_subdivisions", a .geojson file with the polygons of county subdivisions in Florida. Each row is a county subdivision, and each column is information like its geoid, name, county, and state.

This Script Creates:
- Map showing showing the median income (where available) of the county subdivisions of Florida (minus the panhandle) and the ten county subdivisions with the highest max evacuation rate per 1000 residents over an eight hour period during the collection window highlighted in white.
- Chart showing the ten highlighted county subdivisions and their max evacuation rates per 1000 residents, with each bar colored to show approximate median income. 

Results:

Cape Sable had by far the highest max evacuation rate per 1000 residents, but its rate exceeded the population; 16,400 people evacuated per 1000 residents. Cape Sable’s non-normalized evacuation max was 311.6 (significantly less than the highest non normalized max in the dataset, Clay County’s 4182), but its population was only 19. This may indicate an error in the dataset
	The next highest max evacuation rate per 1000 residents was in Glades, Palm Beach County (part of the Miami metro area). Its max rate of 216 evacuees/1000 residents was nearly twice the county subdivision with the next highest rate. 66 people evacuated from Glades in one 8 hour time period at its max, a large chunk of its overall population of 309. Glades’ evacuation rate, however, peaked on October 23, with two other spikes on October 19th . This was well after the date of the hurricane, and further information is needed to determine if it was related to post-storm recovery. Glades also stands out as the lowest Median income of the top ten areas studied- in fact its median income is $16,573 per year, the lowest of any county subdivision in Florida. The $43817 median income of the place with the next highest normalized evacuation rate, Jasper, is nearly three times that of Glades. Jasper’s max evacuation spike (and the three closest spikes to it), also occurred in late October, well after the storm.  This additional information is available by running the calculations at the end of the script.


