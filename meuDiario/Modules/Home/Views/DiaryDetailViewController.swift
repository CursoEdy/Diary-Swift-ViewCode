//
//  DiaryDetailViewController.swift
//  meuDiario
//
//  Created by ednardo alves on 03/07/25.
//

import UIKit
import CoreData

class DiaryDetailViewController: UIViewController {
    
    private var entry: DiaryEntryEntity
//    private let isNew: Bool
    private let context: NSManagedObjectContext
    private let onSave: () -> Void
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Titulo"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 18, weight: .light)
        return textField
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Salvar", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return button
    }()
    
    init(entry: DiaryEntryEntity, context: NSManagedObjectContext, onSave: @escaping () -> Void) {
        self.entry = entry
        self.context = context
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureData()
    }
    
    private func setupView() {
        title = "Editar Entrada"
        view.backgroundColor = .white
        
        [titleTextField, contentTextView, saveButton].forEach{
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalToConstant: 250),
            
            saveButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureData() {
        titleTextField.text = entry.title
        contentTextView.text = entry.content
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        
        entry.title = title
        entry.content = contentTextView.text
        
        do {
            try context.save()
            onSave()
            navigationController?.popViewController(animated: true)
        } catch {
            print("erro ao savar entrada: \(error)")
        }
    }
}
