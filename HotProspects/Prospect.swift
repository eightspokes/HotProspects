//
//  Prospect.swift
//  HotProspects
//
//  Created by Roman on 5/17/23.
//

import Foundation

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
}

@MainActor class Prospects: ObservableObject{
    @Published var people: [Prospect]
    let savedKey = "SavedData"
    init(){
        if let data = UserDefaults.standard.data(forKey: savedKey){
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data){
                people = decoded
                return
            }
        }
        //No saved data
        people = []
    }
    private func save(){
        if let encoded = try? JSONEncoder().encode(people){
            UserDefaults.standard.set(encoded, forKey: savedKey)
        }
    }
    
    func toggle(_ prospect: Prospect){
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    func addProspect(prospect: Prospect){
        people.append(prospect)
        save()
    }
    
}
