//
//  DiaryViewController.swift
//  meuDiario
//
//  Created by ednardo alves on 03/07/25.
//

import UIKit
import CoreData

class DiaryViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var entries: [DiaryEntryEntity] = []
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "buscar por um título..."
        search.searchBarStyle = .minimal
        return search
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Nenhuma entrado no diário ainda."
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Adicionar Entrada", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
        loadEntries()
    }
    
    
    private func setupView() {
        title = "Meu diário"
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(DiaryEntryCell.self, forCellReuseIdentifier: DiaryEntryCell.identifier)
        searchBar.delegate = self
        
        [tableView, addButton, emptyLabel, searchBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addButton.addTarget(self, action: #selector(addEntryTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
        ])
    }
    
    @objc private func addEntryTapped() {
        let newEntry = DiaryEntryEntity(context: context)
        newEntry.id = UUID()
        newEntry.title = "Sem titulo"
        newEntry.content = ""
        newEntry.date = Date()
        
        do {
            try context.save()
            loadEntries()
        } catch {
            print("Erro ao salvar: \(error)")
        }
        
        let detailVC = DiaryDetailViewController(entry: newEntry, context: context) { [weak self] in
            self?.loadEntries()
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func loadEntries(searchText: String? = nil) {
        let request: NSFetchRequest<DiaryEntryEntity> = DiaryEntryEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: true) // mais recente ultimo
        request.sortDescriptors = [sort]
        
        if let text = searchText, !text.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
        }
        
        do {
            entries = try context.fetch(request)
        } catch {
            print("Erro ao carregar entradas: \(error)")
        }
        tableView.reloadData()
        updateEmptyStaleLabel()
    }
    
    private func updateEmptyStaleLabel() {
        emptyLabel.isHidden = !entries.isEmpty
    }
}

extension DiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = entries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryEntryCell.identifier, for: indexPath) as! DiaryEntryCell
        cell.selectionStyle = .none
        cell.configure(with: entry)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = entries[indexPath.row]
        
        let detailVC = DiaryDetailViewController(entry: entry, context: context) { [weak self] in
            self?.loadEntries()
        }
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Exluir") { [weak self] _, _, completion in
            guard let self = self else { return }
            let entry = self.entries[indexPath.row]
            self.context.delete(entry)
            
            do {
                try self.context.save()
                self.entries.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.updateEmptyStaleLabel()
                completion(true)
            } catch {
                print("Erro ao excluir: \(error)")
                completion(false)
            }
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension DiaryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadEntries(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
//        searchBar.showsCancelButton = true
        loadEntries()
    }
}
