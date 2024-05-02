//
//  JournalEntryDetailViewController.swift
//  JRNL
//
//  Created by Vinh Nguyen on 24/04/2024.
//

import UIKit
import MapKit

class JournalEntryDetailViewController: UIViewController {
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyTextView: UITextView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet private weak var ratingView: RatingView!
    
    
    private var selectedJournalEntry: JournalEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Entry Detail"
        setupEntryDetail()
        getMapSnapshot()
    }
    
    static func setJournalEntryDetailViewController(selectedJournalEntry: JournalEntry) -> JournalEntryDetailViewController {
        let viewController = JournalEntryDetailViewController()
        viewController.selectedJournalEntry = selectedJournalEntry
        return viewController
    }
    
    private func setupEntryDetail() {
        dateLabel.text = selectedJournalEntry?.dateString
        ratingView.rating = selectedJournalEntry?.rating ?? 0
        titleLabel.text = selectedJournalEntry?.entryTitle
        bodyTextView.text = selectedJournalEntry?.entryBody
        if let photoData = selectedJournalEntry?.photoData {
            photoImageView.image = UIImage(data: photoData)
        }
    }
    
    private func getMapSnapshot() {
        if let lat = selectedJournalEntry?.latitude,
           let long = selectedJournalEntry?.longitude {
            let options = MKMapSnapshotter.Options()
            options.region = MKCoordinateRegion(center: CLLocationCoordinate2D( latitude: lat, longitude: long),
                                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            options.size = CGSize(width: 300, height: 300)
            let snapShotter = MKMapSnapshotter(options: options)
            snapShotter.start { snapShot, error in
                if let snapShot = snapShot {
                    self.mapImageView.image = snapShot.image
                } else if let error = error {
                    print("snapShot error:  \(error.localizedDescription)")
                }
            }
        } else {
            self.mapImageView.image = nil
        }
    }
}
