//
//  DiaryEntryCell.swift
//  meuDiario
//
//  Created by ednardo alves on 06/07/25.
//

import UIKit

class DiaryEntryCell: UITableViewCell {
    
    static let identifier = "DiaryEntryCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .systemBlue.withAlphaComponent(0.8)
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy - HH:mm" // 07/07/1997 - 10:09
//        formatter.dateFormat = "EEEE, dd MMM yy" // Segunda-feira, 07 Jul 25
        formatter.dateFormat = "dd MMM yyyy, HH:mm" // 07 Jul 2025, 10:09
        return formatter
    }()
    
    //MARK: inicialização
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [titleLabel, dateLabel, previewLabel].forEach{
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            previewLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            previewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            previewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            previewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with entry: DiaryEntryEntity) {
        titleLabel.text = entry.title
        previewLabel.text = entry.content
        if let date  = entry.date {
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = "Data desconhecida."
        }
    }
}
