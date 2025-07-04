//
//  DiaryViewController.swift
//  meuDiario
//
//  Created by ednardo alves on 03/07/25.
//

import UIKit

class DiaryViewController: UIViewController {
    
    private var entries: [DiaryEntry] = [] {
        didSet {
            saveEntries()
            updateEmptyStaleLabel()
        }
    }
    
    private let tableView = UITableView()
    
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
        
        [tableView, addButton, emptyLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addButton.addTarget(self, action: #selector(addEntryTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        let newEntry = DiaryEntry(id: UUID(), title: "Sem titulo", content: "", date: Date())
        entries.insert(newEntry, at: 0)
        tableView.reloadData()
        updateEmptyStaleLabel()
        
        let detailVC = DiaryDetailViewController(entry: newEntry, isNew: true) { [weak self] updateEntry in
            self?.entries[0] = updateEntry
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func saveEntries() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "diaryEntries")
        }
    }
    
    private func loadEntries() {
        if let savedData = UserDefaults.standard.data(forKey: "diaryEntries"),
           let decoded = try? JSONDecoder().decode([DiaryEntry].self, from: savedData) {
            entries = decoded
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = entry.title.isEmpty ? "Sem título" : entry.title
        content.secondaryText = DateFormatter.localizedString(from: entry.date, dateStyle: .short, timeStyle: .short)
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = entries[indexPath.row]
        
        let detailVC = DiaryDetailViewController(entry: entry, isNew: true) { [weak self] updateEntry in
            self?.entries[indexPath.row] = updateEntry
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Exluir") { [weak self] _, _, completion in
            self?.entries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self?.updateEmptyStaleLabel()
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
