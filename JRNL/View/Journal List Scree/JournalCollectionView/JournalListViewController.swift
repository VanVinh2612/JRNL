//
//  JournalListViewController.swift
//  JRNL
//
//  Created by Vinh Nguyen on 02/05/2024.
//

import UIKit

class JournalListViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    private let search = UISearchController(searchResultsController: nil)
    private var filteredTableData: [JournalEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        configSearchView()
        configCollectionView()
        SharedData.shared.loadJournalEntriesData()
    }
    
    private func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(UINib(nibName: JournalListCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: JournalListCollectionViewCell.className)
    }
    
    private func setUpNavigationBar() {
        self.navigationController?.viewControllers.first?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(presentVC))
    }
    
    private func configSearchView() {
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search ..."
        self.navigationItem.searchController = search
    }

    @objc private func presentVC() {
        let newEntryVC = NewEntryViewController()
        self.navigationController?.present(UINavigationController(rootViewController:newEntryVC), animated: true)
        newEntryVC.delegate = self
    }
}
// MARK: - UICollectionViewDataSource
extension JournalListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.search.isActive {
            return self.filteredTableData.count
        } else {
            return SharedData.shared.numberOfJournalEntries()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard SharedData.shared.getAllJournalEntries().indices ~= indexPath.row,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JournalListCollectionViewCell.className, for: indexPath) as? JournalListCollectionViewCell else {
            return UICollectionViewCell()
        }
        let journalEntry: JournalEntry
        if self.search.isActive {
            journalEntry = filteredTableData[indexPath.row]
        } else {
            journalEntry = SharedData.shared.getJournalEntry(index: indexPath.row)
        }
        cell.setupCell(journalEntry: journalEntry)
        return cell
    }
    
}
// MARK: - UITableViewDelegate
extension JournalListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard SharedData.shared.getAllJournalEntries().indices ~= indexPath.row else { return }
        let journalEntry: JournalEntry
        if self.search.isActive {
            journalEntry = filteredTableData[indexPath.row]
        } else {
            journalEntry = SharedData.shared.getJournalEntry(index: indexPath.row)
        }
        let journalEntryDetailVC = JournalEntryDetailViewController.setJournalEntryDetailViewController(selectedJournalEntry: journalEntry)
        
        navigationController?.pushViewController(journalEntryDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(actionProvider:  { (elements) -> UIMenu? in
            let delete = UIAction(title: "Delete") { (action) in
                if self.search.isActive {
                    if let index = indexPaths.first?.item {
                        let selectedJournalEntry = self.filteredTableData[index]
                        self.filteredTableData.remove(at: index)
                        SharedData.shared.removeSelectedJournalEntry(selectedJournalEntry)
                    }
                } else {
                    if let index = indexPaths.first?.item {
                        SharedData.shared.removeJournalEntry(index: index)
                    }
                }
                SharedData.shared.saveJournalEntriesData()
                self.collectionView.reloadData()
            }
            return UIMenu(children: [delete])
        })
        return config
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension JournalListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var columns: CGFloat
        if (traitCollection.horizontalSizeClass == .compact) {
            columns = 1
        } else {
        columns = 2
        }
        let viewWidth = collectionView.frame.width
        let inset = 10.0
        let contentWidth = viewWidth - inset * (columns + 1)
        let cellWidth = contentWidth / columns
        let cellHeight = 90.0
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - NewEntryDelegate
extension JournalListViewController: NewEntryDelegate {
    func addNewEntry(_ newJournalEntry: JournalEntry) {
        SharedData.shared.addJournalEntry(newJournalEntry: newJournalEntry)
        SharedData.shared.saveJournalEntriesData()
        self.collectionView.reloadData()
    }
}
//MARK: - UISearchResultsUpdating
extension JournalListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        filteredTableData.removeAll()
        for journalEntry in SharedData.shared.getAllJournalEntries() {
            if journalEntry.entryTitle.lowercased().contains(searchBarText.lowercased()) {
                filteredTableData.append(journalEntry)
            }
        }
        self.collectionView.reloadData()
    }
}
