# Map median income by county subdivision and chart max evacuation
#Setup############################################################

#install.packages("ggpubr")
#install.packages("scales")
library(dplyr)
library(readr)
library(ggplot2)
library(viridis)
library(ggpubr) 
library(tidyr)
library(tidygraph)
library(GGally)
library(sf)
library(ggspatial)
library(lubridate)
library(stringr)
library(scales)

# Load projections
aea <- "+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
# Equal Distance projection
aed <- "+proj=eqdc +lat_0=0 +lon_0=0 +lat_1=33 +lat_2=45 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs "
# EPSG:4326 (WGS 84) projection
wgs <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

#Load Data###################################################
#!!!!!!!This was done on a local version of R. For Positcloud use, update file path to "data/evacuation/edges.rds" or the relevant version of it!!!!!!!!!!!!!

edges2 = read_rds("edges.rds")

nodes = read_rds("nodes.rds")

#Uncomment to view/explore data
#glimpse(edges2)
#glimpse(nodes)
#edges2 has the from and to geoids in it

#Prepare nodes data
nodes = data %>%
  activate("nodes") %>%
  as_tibble() %>%
  st_as_sf() %>%
  select(median_income, geoid, pop)

#Read in county subdivisions geojson

countysubs <- read_sf("county_subdivisions.geojson") %>%
  as_tibble() %>%
  st_as_sf()

#Join nodes to countysubs geometries, drop any rows without a valid join
csn = countysubs %>%
  st_join(nodes, left=FALSE)

#View joined data
#glimpse(csn)

#Calculate the max evacuation spike to map for each "from" geoid in the edges dataset

edgesmax = edges2 %>%
  #   filter(evacuation>0) %>%
  group_by(from_geoid) %>%
  summarize(y=max(evacuation, na.rm=TRUE))

node2 <- nodes %>%
  rename(from_geoid=geoid)

joined2 <- left_join(edgesmax, node2, by = "from_geoid")%>%
  st_as_sf

#Join to create a countysubs table with an evacuation rate column, filtering for places with population greater than 0
#Calculate evacuation spike per 1000 residents

csnedges = countysubs %>%
  st_join(joined2, left=FALSE)%>%
  rename(evacuation=y) %>%
  filter(pop>0) %>%
  filter(state == "FL")%>%
  mutate(evacuationrate=((evacuation/pop)*1000))

csnedgestop10 = csnedges %>%
  filter(evacuationrate>49)%>%
  mutate(roundedevacmax=round(evacuationrate))

####VISUALIZATIONS#################################################
#Create a map showing the places with the top ten MAXIMUM/1000 people evacuation rates in FL highlighted in white, along with median income

map1 <- ggplot() +
  geom_sf(data = csn, mapping = aes(fill = median_income))+
  scale_fill_viridis(option = "plasma", begin = .1, end = 0.9, alpha = 0.75, na.value = "gray", 
                     labels = scales::label_dollar(prefix = "$", big.mark = ",")) +
  geom_sf(data = csnedgestop10, fill=NA, color="white", linewidth = 0.5) +
  coord_sf(xlim = c(-84.2, -79.9), ylim = c(24.5, 31))+
  theme(panel.background = element_rect(fill = "#D9E6F5"), #Set Background to blue
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),  # Remove grid lines
        legend.title = element_text(size = 9),
        legend.text = element_text(size = 7),
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 6),  # Space out axis labels
        axis.text.y = element_text(size = 6),
        plot.title = element_text(size = 13),
        plot.subtitle = element_text(size = 9)) +
  labs(title= "Where Did Evacuation Rates Spike?", 
       subtitle= "County Subdivisions During Hurricane Dorian, 2019 \nTop Ten Evacuation Spikes/1000 Residents in White",
       fill = "Median Income")

map1

#Create a chart showing the top ten from above with a color scale corresponding to their median incomes

na.value.forplot <- 'grey'

chart1 <- 
  ggplot(data = csnedgestop10, mapping = aes(x = reorder(name, evacuationrate),
                                             y = evacuationrate, fill = median_income)) +
  geom_col(color = "black") +
  scale_fill_viridis(option = "plasma",  begin = .1, end = 0.9, alpha = 0.75, na.value = "gray",
                     labels = scales::label_dollar(prefix = "$", big.mark = ",")) +
  scale_y_continuous(trans = "log", labels = scales::label_number(accuracy = 1)) +
  coord_flip() +
  theme_bw() +
  labs(title= "Where Did Evacuation Rates Spike?", subtitle= "Top Ten Evacuation Spikes from Hurricane Dorian, 2019", y = "Max Evacuation Rate/1000 Residents",
       x = "County Subdivision", caption = "More than the entire population of Cape Sable evacuated at its max. This may indicate error.",
       fill = "Median Income")+
  theme(plot.caption = element_text(hjust = 0.5))+
  geom_text(aes(label = paste0(roundedevacmax, " Evacuees")), hjust= 1.2, vjust = 0.5, size = 3, color= "white")
  
  chart1

#Futher Analysis################################################
#Get info on when the evacuation spikes occurred and whether any similar spikes happened for written analysis

edgesglades <- edges2 %>%
  filter(from_geoid == "1209991274", evacuation>50)

edgesjasper <- edges2 %>%
  filter(from_geoid == "1204791651", evacuation>900)

edgesnorthcolumbia <- edges2 %>%
  filter(from_geoid == "1204791651", evacuation>900)

edgeswestbrevard <- edges2 %>%
  filter(from_geoid == "1200993588", evacuation>600)
