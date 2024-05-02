//
//  NewEntryViewController.swift
//  JRNL
//
//  Created by Vinh Nguyen on 24/04/2024.
//

import UIKit
import CoreLocation

protocol NewEntryDelegate: AnyObject {
    func addNewEntry(_ newJournalEntry: JournalEntry)
}

class NewEntryViewController: UIViewController {

    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var bodyTextView: UITextView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var getLocationSwitch: UISwitch!
    @IBOutlet private weak var getLocationSwitchLabel: UILabel!
    @IBOutlet private weak var ratingView: RatingView!
    private var newJournalEntry: JournalEntry?
    weak var delegate: NewEntryDelegate?
    private var saveButton: UIBarButtonItem!
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        titleTextField.delegate = self
        bodyTextView.delegate = self
        updateSaveButtonState()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    private func setUpNavigationBar() {
        self.navigationItem.title = "New Entry"
        saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(unwindNewEntrySave))
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(unwindNewEntryCancel))
    }
    
    @objc private func unwindNewEntryCancel() {
        self.dismiss(animated: true)
    }
    
    @objc private func unwindNewEntrySave() {
        let title = titleTextField.text ?? ""
        let body = bodyTextView.text ?? ""
        let photo = photoImageView.image
        let rating = 3
        let lat = currentLocation?.coordinate.latitude
        let long = currentLocation?.coordinate.longitude
        newJournalEntry = JournalEntry(rating: rating, title: title, body: body,
        photo: photo, latitude: lat, longitude: long)
        if let newJournalEntry = newJournalEntry {
            delegate?.addNewEntry(newJournalEntry)
            self.dismiss(animated: true)
        }
    }
    
    private func updateSaveButtonState() {
        let textFieldText = titleTextField.text ?? ""
        let textViewText = bodyTextView.text ?? ""
        if getLocationSwitch.isOn {
            saveButton.isEnabled = !textFieldText.isEmpty
            && !textViewText.isEmpty
            && !(currentLocation == nil)
          } else {
            saveButton.isEnabled = !textFieldText.isEmpty && !textViewText.isEmpty
        }
    }
    @IBAction private func getLocationSwitchValueChanged(_ sender: UISwitch) {
        if getLocationSwitch.isOn {
            getLocationSwitchLabel.text = "Getting location..."
            locationManager.requestLocation()
          } else {
            currentLocation = nil
            getLocationSwitchLabel.text = "Get location"
          }
    }
    
    @IBAction private func getPhoto(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        #if targetEnvironment(simulator)
        imagePickerController.sourceType = .photoLibrary
        #else
        imagePickerController.sourceType = .camera
        imagePickerController.showsCameraControls = true
        #endif
        present(imagePickerController, animated: true)
    }
}
// MARK: - UITextFieldDelegate
extension NewEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
}
// MARK: - UITextViewDelegate
extension NewEntryViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
         updateSaveButtonState()
    }
}
// MARK: - CLLocationManagerDelegate
extension NewEntryViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let myCurrentLocation = locations.first {
            currentLocation = myCurrentLocation
            getLocationSwitchLabel.text = "Done"
            updateSaveButtonState()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
// MARK: - UIImagePickerControllerDelegate
extension NewEntryViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage]
                as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let smallerImage = selectedImage.preparingThumbnail(of: CGSize(width: 300, height: 300))
        photoImageView.image = smallerImage
        dismiss(animated: true)
    }
}
// MARK: - UINavigationControllerDelegate
extension NewEntryViewController: UINavigationControllerDelegate {
    
}
