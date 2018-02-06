//
//  ViewController.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 12/28/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//

import UIKit
import CoreData

class RoomTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    // MARK: Properties
    
    // Get the AppDelegate for the stack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var fetchedResultsController: NSFetchedResultsController<Room> = { () -> NSFetchedResultsController<Room> in
        
        let stack = delegate.stack
        
        let fetchRequest = NSFetchRequest<Room>(entityName: "Room")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        roomTableView.reloadData()
        
        print("fetchresult called")
        return fetchedResultsController
    }()
    
    @IBOutlet weak var roomTableView: UITableView!
    @IBOutlet weak var roomInputsView: UIView!
    @IBOutlet weak var genderControl: UISegmentedControl!
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var roomNameTextfield: UITextField!
    @IBOutlet weak var createNavButton: UIBarButtonItem!
    @IBOutlet weak var cancelNavButton: UIBarButtonItem!
    @IBOutlet weak var translucentBackground: UIImageView!
    
    let inputTextFieldDelegate = RoomTextFieldDelegate()
    var selectedRoom: [Room] = []
    
    //Hide the status bar to show navigation bar at very top
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set buttons
        roomInputsView.layer.cornerRadius = 10
        toggleNavButtons(CreatingRoomOn: false)
        
        // Set delegates
        roomNameTextfield.delegate = inputTextFieldDelegate
        roomTableView.delegate = self
        roomTableView.dataSource = self
        
        // Initial Fetch Request
        executeSearch()
    }

    // Bring the user form forward in order to create a room.
    
    @IBAction func bringRoomInputsForward(_ sender: Any) {
        
        translucentBackground.alpha = 0.0
        roomInputsView.alpha = 0.0
        view.bringSubview(toFront: translucentBackground)
        view.bringSubview(toFront: roomInputsView)
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: [], animations: {
            
            self.translucentBackground.alpha = 0.75
            self.roomInputsView.alpha = 1.0
            
        }, completion: nil)
        
        toggleNavButtons(CreatingRoomOn: true)
    }

    
    // Move the user form back behind the table when the form is no longer needed.
    
    @IBAction func cancelNewRoom(_ sender: Any) {
        
        self.view.sendSubview(toBack: roomInputsView)
        self.view.sendSubview(toBack: translucentBackground)
        toggleNavButtons(CreatingRoomOn: false)
        roomNameTextfield.text = ""
        
    }
    
    // Based on user inputs create a room entity, poster bin entity, and link the two.
    
    @IBAction func createNewRoom(_ sender: Any) {
        
        if roomNameTextfield.text != "" {
            
            let name = roomNameTextfield.text
            var gender = ""
            
            switch genderControl.selectedSegmentIndex {
                
            case 0:
                gender = "boy"
            case 1:
                gender = "girl"
            default:
                break
            }
            
            let newRoom = Room(name: name!, gender: gender, context: fetchedResultsController.managedObjectContext)
            
            let newBin = PosterBin(context: fetchedResultsController.managedObjectContext)
            
            newRoom.posterBin = newBin
            
            delegate.stack.save()
            
            self.view.sendSubview(toBack: roomInputsView)
            self.view.sendSubview(toBack: translucentBackground)
            toggleNavButtons(CreatingRoomOn: false)
            roomNameTextfield.text = ""
            
        } else {
            
            showAlert("Empty Name Value.", "Please give your room a name.")
        
        }
    }
    
    // helper to toggle Nav buttons when view moves forward to create room entity.
    
    func toggleNavButtons(CreatingRoomOn: Bool) {
        
        switch CreatingRoomOn {
            
        case true:
            
            createNavButton.isEnabled = false
            cancelNavButton.isEnabled = true
            
        case false:
            
            createNavButton.isEnabled = true
            cancelNavButton.isEnabled = false

        }
    }
    
    
    // Prepare for seque by injecting newly created room entity into next View Controller to allow for proper setting up of room.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == "displayRoom" {
            
            if let RoomVC = segue.destination as? RoomVC {
                
                RoomVC.selectedRoomArray = selectedRoom

            }
        }
    }
    
    
    // MARK: TableView Fetches
    
    func executeSearch() {
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
            
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
    }
    
    
    // MARK: TableView Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultsController.sections![section].numberOfObjects
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let room = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
        
        cell.textLabel?.text = room.name
        cell.detailTextLabel?.text = room.gender
        
        return cell
    }
    
    // Delete entity when row is deleted from table with swiping motion.
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let deletedRoom = fetchedResultsController.object(at: indexPath)
            
            fetchedResultsController.managedObjectContext.delete(deletedRoom)
            
            delegate.stack.save()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRoomEntity = fetchedResultsController.object(at: indexPath)
        
        print(selectedRoomEntity)
        print("Room at Row Tapped")
        
        selectedRoom.append(selectedRoomEntity)
        
        print("this is selected Room Array \(selectedRoom)")
        
        performSegue(withIdentifier: "displayRoom", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedRoom.removeAll()
    }
    

    
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        roomTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            roomTableView.insertSections(set, with: .fade)
        case .delete:
            roomTableView.deleteSections(set, with: .fade)
        default:
         
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            roomTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            roomTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            roomTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            roomTableView.deleteRows(at: [indexPath!], with: .fade)
            roomTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        roomTableView.endUpdates()
    }
    
    

}

