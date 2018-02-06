//
//  PosterBinVC.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 1/4/18.
//  Copyright © 2018 Andrew Delaney. All rights reserved.
//

import UIKit
import CoreData


class PosterBinVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,  NSFetchedResultsControllerDelegate, UITextFieldDelegate {

    
    // MARK: Properties
    
    // MARK: - Instance Variables
    lazy var fetchedResultsController: NSFetchedResultsController<Poster> = { () -> NSFetchedResultsController<Poster> in
        
        let stack = delegate.stack
        
        let fetchRequest = NSFetchRequest<Poster>(entityName: "Poster")
        
        fetchRequest.sortDescriptors = []
        
        let binPred = NSPredicate(format: "posterBin == %@", argumentArray: roomPosterBin)

        fetchRequest.predicate = binPred
        
        print(binPred)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        print("fetchresult called")
        return fetchedResultsController
    }()
    
    @IBOutlet weak var posterBinCollectionView: UICollectionView!
    @IBOutlet weak var addToRoomButton: UIBarButtonItem!
    @IBOutlet weak var tappedPosterImage: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var downloadActivity: UIActivityIndicatorView!
    
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    // Get the AppDelegate for the stack
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let searchTextFieldDelegate = RoomTextFieldDelegate()
    
    var selectedRoom: [Room] = []
    var roomPosterBin: [PosterBin] = []
    var selectedPoster: UIImageView?
    var selectedPosterNumber: Int?
    var downloadedURLArray: [URL] = []
    var posterToAdd: NSData?
    
    //Hide the status bar to show navigation bar at very top
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting delegates
        
        posterBinCollectionView.delegate = self
        posterBinCollectionView.dataSource = self
        searchTextField.delegate = searchTextFieldDelegate
        
        // Setting buttons
        
        addToRoomButton.isEnabled = false
        
        // Setting up image
        
        tappedPosterImage.image = selectedPoster?.image
        tappedPosterImage.contentMode = .scaleAspectFill
        configureDownloadIndicator(isON: false)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Initial Search Execution
        
        executeSearch()
        
    }
    
    // Layout the collection view
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        // Layout the collection view so that cells take up 1/3 of the width,
        // with no space in-between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let space:CGFloat = 1.0
        
        //Show three cells across for all orientations
        
        let width = (UIScreen.main.bounds.width - (2 * space)) / 3.0
        
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: width, height: width)
        posterBinCollectionView.collectionViewLayout = layout
    }
    
    // Navigate back to the Room View
    
    @IBAction func backToRoomTransition(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
    // Add selected Poster to the Room Entity and transition back to the Room
    
    @IBAction func addPosterToRoom(_ sender: Any) {
        
        let stack = delegate.stack
        
        let roomObjectID = selectedRoom[0].objectID
        
        let roomCopy = stack.context.object(with: roomObjectID)
        
        switch selectedPosterNumber {
        case 1? :
            roomCopy.setValue(posterToAdd, forKey: "poster1")
        case 2? :
            roomCopy.setValue(posterToAdd, forKey: "poster2")
        case 3? :
            roomCopy.setValue(posterToAdd, forKey: "poster3")
        default:
            break
        }
        
        stack.save()
        
        navigationController?.popViewController(animated: true)
        
    }
    
    // Helper functiont to configure downloading indicator over search button
    
    func configureDownloadIndicator(isON: Bool) {
    
        if isON == true {
            
            downloadActivity.isHidden = false
            downloadActivity.startAnimating()
            
        } else {
            
            downloadActivity.isHidden = true
            downloadActivity.stopAnimating()
        }
        
    }
    
    // Initiate download from Flickr based on user search criteria.  Search will not occur if the field is blank and an alert will provide instructions.
    
    @IBAction func searchForPhotos(_ sender: Any) {
        
        let searchText = searchTextField.text
        
        let stack = delegate.stack
        
        if searchText != "" {
            
            configureDownloadIndicator(isON: true)
            
            // All of the handling and manipulating of the data from JSON is contained in the Flickr Client Class.
            
            FlickrClient.sharedInstance().taskForGetRandomPage(search: searchText!) { (result, error) in
                
                if let error = error {
                    
                    performUIUpdatesOnMain {
                        
                        self.configureDownloadIndicator(isON: false)
                        self.showAlert("Failed Search", error)
                        
                        print("FAILED to get Random")
                        
                    }
                    
                } else {
                    
                    FlickrClient.sharedInstance().taskForGetPhotosFromSearch(search: searchText!, randomPage: result!, completionForPosterPhotos: { (result, error) in
                        
                        if let error = error {
                            
                            performUIUpdatesOnMain {
                                
                                self.configureDownloadIndicator(isON: false)
                                self.showAlert("Failed Search", error)
                                
                                print("FAILED to get Photos!")
                                
                            }
                            
                        } else {
                            
                            
                            // Delete existing photos in Poster Bin Entity
                            
                            for poster in self.fetchedResultsController.fetchedObjects!{
                                
                                stack.context.delete(poster)
                            }
                            
                            // Convert images into Poster Entities and associate them with the Poster Bin.
                            
                            self.downloadedURLArray = result!
                            
                            self.convertToPosterEntity(photoURLArray: self.downloadedURLArray)
                            self.configureDownloadIndicator(isON: false)
                        }
                    })
                }
            }
            
        } else {
            
            self.configureDownloadIndicator(isON: false)
            showAlert("Empty Search", "Please fill in search field.")
            
        }
    }
    
    
    // Take array of URLs and a PosterBin and create Poster Entities.  First quickly create a nil image and then as images download, replace them in the Entity.  The fetchedresultscontroller will update the placeholders as they download.
    
    func convertToPosterEntity(photoURLArray: [URL]) {
        
        let stack = delegate.stack
        
        var createdPosterArray: [Poster] = []
        
        // Create the Photo and use a nil placeholder.  Then store them in an Array of Poster Entities.
        
        stack.performBackgroundBatchOperation { (workercontext) in
            
            for _ in photoURLArray {
                
                let newPoster = Poster(posterImage: nil, context: workercontext)
                
                let posterBinObjectID = self.roomPosterBin[0].objectID
                
                let posterBinCopy = workercontext.object(with: posterBinObjectID)
                
                newPoster.posterBin = (posterBinCopy as! PosterBin)
                
                createdPosterArray.append(newPoster)
            }
            
            self.saveContextHelper(context: workercontext)
            
            // Get the last index of the Poster Entities Array so that each Poster can be updated with an image.  Since the only property of the Poster is an image, it doesn't matter in what order they are updated with a downloaded image.
            
            let lastIndex = createdPosterArray.count - 1
            
            for i in 0...lastIndex {
                
                let photoToDownload = photoURLArray[i]
                let posterEntity = createdPosterArray[i]
                
                if let imageData = try? Data(contentsOf: photoToDownload){
                    
                    posterEntity.posterImage = imageData as NSData
                    
                    self.saveContextHelper(context: workercontext)
                }
            }
        }
        
    }
    
    
    // Helper function for saving contexts.
    
    func saveContextHelper(context: NSManagedObjectContext) {
        
        // Save it to the parent context, so normal saving
        // can work
        do {
            try context.save()
            print("Saved!")
            
        } catch {
            fatalError("Error while saving backgroundContext: \(error)")
        }
        
    }
    
    
    // MARK: Core Data Collection View Datasource
    
    // Set cell image for Poster Entity.  If the image hasn't downloaded yet, show an activity indicator and a cool placeholder image.  Once it downloads, hide the indicator and display the actual image.
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "downloadedPoster", for: indexPath) as! PosterCollectionViewCell

        let poster = fetchedResultsController.object(at: indexPath)
        
        if poster.posterImage != nil {
            
            cell.downloadActivityIndicator.stopAnimating()
            cell.downloadActivityIndicator.isHidden = true
            cell.posterImage.image = UIImage(data: poster.posterImage! as Data)
            cell.posterImage.contentMode = .scaleAspectFill
            
        } else {
            
            cell.downloadActivityIndicator.isHidden = false
            cell.downloadActivityIndicator.startAnimating()
            cell.posterImage.image = #imageLiteral(resourceName: "cellPlaceHolder")
            cell.posterImage.contentMode = .scaleAspectFill
        }

        return cell
    }
    
    // MARK: Core Data Collection View Delegate
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    // When a Poster is selected, highlight it and enable the Add to Room button.
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("called")
       
        let highlightedPoster = fetchedResultsController.object(at: indexPath)
        
        posterToAdd = highlightedPoster.posterImage
        
        addToRoomButton.isEnabled = true
        
    }
    
    
    // MARK: - CoreData Collection View (Fetches)
    
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
    
    
    
    // MARK: - CoreData NSFetchedResultsControllerDelegate
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
     
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
     
        switch(type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
       posterBinCollectionView.performBatchUpdates({() -> Void in

            for indexPath in insertedIndexPaths {
                posterBinCollectionView.insertItems(at: [indexPath])
            }

            for indexPath in deletedIndexPaths {
                posterBinCollectionView.deleteItems(at: [indexPath])
            }

            for indexPath in updatedIndexPaths {
                posterBinCollectionView.reloadItems(at: [indexPath])
            }

        }, completion: nil)
    }


}
