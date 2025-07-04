//
//  DiaryEntry.swift
//  meuDiario
//
//  Created by ednardo alves on 03/07/25.
//

import Foundation

struct DiaryEntry: Codable {
    let id: UUID
    var title: String
    var content: String
    let date: Date
}
