//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Roman on 5/17/23.
//

import SwiftUI
import CodeScanner
import UserNotifications
struct ProspectsView: View {
    enum FilterType{
        case none, contacted, uncontacted
    }
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    
    let filter: FilterType
    
    func handleScan( result: Result<ScanResult,ScanError>){
        isShowingScanner = false
        switch result{
        case .success(let result):
            let details = result.string.components(separatedBy: " ")
            guard details.count == 2 else {return}
            let person  = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.addProspect(prospect: person)
            
        case .failure(let error):
            print("Failed to read qr code \(error.localizedDescription)")
            
        }
        
    }
    func addNotification(for prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        center.getNotificationSettings { setting in
            if setting.authorizationStatus == .authorized {
                addRequest()
            }else{
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success,error  in
                    if success{
                        addRequest()
                    }else{
                        print("Error authorization")
                    }
                }
            }
        }
        
    }
    
    
    var body: some View {
        NavigationView{
            
            
            List{
                ForEach(filteredProspects){ prospect in
                    VStack(alignment: .leading){
                        Text(prospect.name)
                            .font(.headline)
                        Text(prospect.emailAddress)
                            .background(.secondary)
                        
                    }
                    .swipeActions{
                        if prospect.isContacted{
                            Button{
                                prospects.toggle(prospect)
                               
                            }label: {
                                Label("Mark Uncontacted",systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        }else{
                            Button{
                                prospects.toggle(prospect)
                            }label: {
                                Label("Mark Uncontacted",systemImage: "person.crop.circle.fill.badge.checkmark")
                            }.tint(.green)
                        }
                    }
                }
            }
                .navigationTitle(title)
                .toolbar {
                    Button {
                        isShowingScanner = true
                    }label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
                .sheet(isPresented: $isShowingScanner){
                    CodeScannerView(codeTypes: [.qr], simulatedData: "sample data", completion: handleScan)
                }
        }
        
        
    }
    var title: String{
        switch filter{
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
            
            
        }
    }
    var filteredProspects: [Prospect]{
        switch filter{
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
            
            
        }
    }
}





struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
