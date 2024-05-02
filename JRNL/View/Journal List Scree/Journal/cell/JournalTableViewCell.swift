//
//  JournalTableViewCell.swift
//  JRNL
//
//  Created by Vinh Nguyen on 24/04/2024.
//

import UIKit

class JournalTableViewCell: UITableViewCell {
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(journalEntry: JournalEntry) {
        if let photoData = journalEntry.photoData {
          photoImageView.image = UIImage(data: photoData)
        }
        dateLabel.text = journalEntry.dateString
        titleLabel.text = journalEntry.entryTitle
    }
    
}
