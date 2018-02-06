//
//  RoomVC.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 1/2/18.
//  Copyright © 2018 Andrew Delaney. All rights reserved.
//

import UIKit

class RoomVC: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var roomImage: UIImageView!
    @IBOutlet weak var poster1Image: UIImageView!
    @IBOutlet weak var poster2Image: UIImageView!
    @IBOutlet weak var poster3Image: UIImageView!
    
    var selectedRoomArray: [Room] = []
    var tappedPoster: UIImageView?
    var tappedPosterNumber: Int?
    
    // Get the AppDelegate for the stack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    //Hide the status bar to show navigation bar at very top
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpRoom(roomArray: selectedRoomArray)
    
    }

    // Sets up the room based on the entity attributes.  This determines the background used and what posters are placed on the wall.
    
    func setUpRoom(roomArray: [Room]) {
        
        let selectedRoom = selectedRoomArray[0]
        
        // Setting Background - Gender
        
        if selectedRoom.gender == "boy" {
            roomImage.image = #imageLiteral(resourceName: "boysRoom")
        } else {
            roomImage.image = #imageLiteral(resourceName: "girlsRoom")
        }
        
        // Setting Poster 1
        
        if selectedRoom.poster1 == nil {
            
            poster1Image.image = #imageLiteral(resourceName: "posterPlaceholder")
            
        } else {
            
            poster1Image.image = UIImage(data: selectedRoom.poster1! as Data)
            poster1Image.alpha = 1.0
        }
        
        // Setting Poster 2
        
        if selectedRoom.poster2 == nil {
            
            poster2Image.image = #imageLiteral(resourceName: "posterPlaceholder")
            
        } else {
            
            poster2Image.image = UIImage(data: selectedRoom.poster2! as Data)
            poster2Image.alpha = 1.0
        }
        
        // Setting Poster 3
        
        if selectedRoom.poster3 == nil {
            
            poster3Image.image = #imageLiteral(resourceName: "posterPlaceholder")
            
        } else {
            
            poster3Image.image = UIImage(data: selectedRoom.poster3! as Data)
            poster3Image.alpha = 1.0
        }
    }

    
    // Navigate back to previous VC
    
    @IBAction func backToRoom(_ sender: Any) {

        navigationController?.popViewController(animated: true)
        
    }
    
    
    // When Poster 1 is tapped, Navigate to PosterBin VC where more photos/posters can be found.
    
    @IBAction func poster1TransitionToBin(_ sender: Any) {
        
        tappedPoster = poster1Image
        tappedPosterNumber = 1
        
        performSegue(withIdentifier: "displayPosterBin", sender: self)

    }
    
    // When Poster 2 is tapped, Navigate to PosterBin VC where more photos/posters can be found.
    
    @IBAction func poster2TransitionToBin(_ sender: Any) {
        
        tappedPoster = poster2Image
        tappedPosterNumber = 2
        
        performSegue(withIdentifier: "displayPosterBin", sender: self)

    }
    
    // When Poster 3 is tapped, Navigate to PosterBin VC where more photos/posters can be found.
    
    @IBAction func poster3TransitionToBin(_ sender: Any) {
        
        tappedPoster = poster3Image
        tappedPosterNumber = 3
        
        performSegue(withIdentifier: "displayPosterBin", sender: self)

    }
    
    
    // Prepare for seque by injecting Room Entity, PosterBin Entity, and the Selected Poster number and image into the PosterBin VC.  These will be used to set up the Collection View with previously downloaded images that are associated with this specific Room and PosterBin.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == "displayPosterBin" {
            
            if let PosterBinVC = segue.destination as? PosterBinVC {
              
                let currentRoom = selectedRoomArray[0]
                
                PosterBinVC.roomPosterBin.append(currentRoom.posterBin!)
                PosterBinVC.selectedRoom.append(selectedRoomArray[0])
                PosterBinVC.selectedPoster = tappedPoster!
                PosterBinVC.selectedPosterNumber = tappedPosterNumber!
                
            }
        }
        
    }
    
    
    
    
}
