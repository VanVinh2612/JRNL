//
//  ViewController.swift
//  JRNL
//
//  Created by Vinh Nguyen on 24/04/2024.
//

import UIKit

class JournalViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private let search = UISearchController(searchResultsController: nil)
    private var filteredTableData: [JournalEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        configSearchView()
        configTableView()
        SharedData.shared.loadJournalEntriesData()
        
    }

    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: JournalTableViewCell.className, bundle: nil), forCellReuseIdentifier: JournalTableViewCell.className)
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
// MARK: - UITableViewDataSource
extension JournalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.search.isActive {
            return self.filteredTableData.count
        } else {
            return SharedData.shared.numberOfJournalEntries()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard SharedData.shared.getAllJournalEntries().indices ~= indexPath.row,
              let cell = tableView.dequeueReusableCell(withIdentifier: JournalTableViewCell.className, for: indexPath) as? JournalTableViewCell else {
            return UITableViewCell()
        }
        let journalEntry: JournalEntry
        if self.search.isActive {
            journalEntry = filteredTableData[indexPath.row]
        } else {
            journalEntry = SharedData.shared.getJournalEntry(index: indexPath.row)
        }
        cell.setupCell(journalEntry: journalEntry)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
// MARK: - UITableViewDelegate
extension JournalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if self.search.isActive {
                let selectedJournalEntry = filteredTableData[indexPath.row]
                filteredTableData.remove(at: indexPath.row)
                SharedData.shared.removeSelectedJournalEntry(selectedJournalEntry)
            } else {
                SharedData.shared.removeJournalEntry(index: indexPath.row)
            }
            SharedData.shared.saveJournalEntriesData()
            tableView.reloadData()
        }
    }
}
// MARK: - NewEntryDelegate
extension JournalViewController: NewEntryDelegate {
    func addNewEntry(_ newJournalEntry: JournalEntry) {
        SharedData.shared.addJournalEntry(newJournalEntry: newJournalEntry)
        SharedData.shared.saveJournalEntriesData()
        tableView.reloadData()
    }
}
//MARK: - UISearchResultsUpdating
extension JournalViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        filteredTableData.removeAll()
        for journalEntry in SharedData.shared.getAllJournalEntries() {
            if journalEntry.entryTitle.lowercased().contains(searchBarText.lowercased()) {
                filteredTableData.append(journalEntry)
            }
        }
        self.tableView.reloadData()
    }
}
