# DesignMyRoomProject

The purpose of Design My Room is to be a fun app where the user can create a room and decorate its wall with posters from images downloaded from Flickr.  

## Installation
```git
 git clone https://github.com/acdelaney/DesignMyRoomProject.git 
```

## Usage

On launch, Design My Room opens to a table view where previously created rooms are displayed.  Users create rooms using the navigation button to prompt a form and by providing a name and gender for the room (boy or girl).  Once a room is created it is displayed in the table view.  Sliding a room to the left generates a delete button.  Selecting the delete button removes the row from the table as well as the associated room from the Core Data database.  Selecting a room navigates to the Room view.

The Room view loads a background image based on the gender of the room.  The first time a room is viewed, three translucent squares with dashed outlines will appear on the wall indicating a spot for a poster.  If the user taps one of the posters, the view transitions to the Poster Bin view.

The Poster Bin view displays a collection view for the previously downloaded posters, a search text field, search button, and the image of the tapped poster so the user can see what poster they will be changing.  The user can add text to the text field to act as search criteria and click the search button.  Images will be downloaded from Flickr using the Alamofire library that are related to the search criteria (*The API Key has been removed since this is a portfolio project*).  Each time the button is selected, twenty new images will be downloaded and stored as posters associated with this Room’s Poster Bin as well as discard of the previous posters.  Selecting a poster will highlight it and enable the Add To Room button on the tool bar.  Clicking the Add To Room button will replace the image property for the Room’s selected Poster and navigate back to the Room view where the selected poster will be displayed on the wall.  These posters will be persisted and can be changed repeatedly following this process.  






