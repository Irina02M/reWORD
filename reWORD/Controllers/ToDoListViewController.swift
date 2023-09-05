
import UIKit
import SwipeCellKit
import UserNotifications

class ToDoListViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    
    
    var itemArray = [Item]()
    let center = UNUserNotificationCenter.current()
    var newArray: [String] = []
    var number = 0
    var timesAday = 1
    
    @IBOutlet weak var buttonSwitch: UISwitch!
    var buttonSwitchCheck = false
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid


    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        center.delegate = self
        center.requestAuthorization(options: [.badge,.sound,.alert]) { granted, error in
            if error == nil {
                print("User permission is granted : \(granted)")
            }
        }
         
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                        willPresent notification: UNNotification,
                                        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
                 completionHandler([.sound,.alert])
            }
        
        
        
        let newItem = Item()
        newItem.word = "arrive"
        newItem.meaning = "to reach some place"
        itemArray.append(newItem)
        newArray.append(newItem.word + ": " + newItem.meaning)
        let newItem2 = Item()
        newItem2.word = "attack"
        newItem2.meaning = "to fight or to hurt"
        itemArray.append(newItem2)
        newArray.append(newItem2.word + ": " + newItem2.meaning)
        let newItem3 = Item()
        newItem3.word = "bottom"
        newItem3.meaning = "the lowest part"
        itemArray.append(newItem3)
        newArray.append(newItem3.word + ": " + newItem3.meaning)
        
        loadItems()
        print("array :")
        print(newArray)
        print(number)
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
             completionHandler([.sound,.alert])
        }


    
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.word + ": " + item.meaning
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   
    
    // Notifications
    
    @IBAction func setNotifications(_ sender: UIBarButtonItem) {
            
        let alert = UIAlertController(title: "SET NOTIFICATIONS", message: "0 - turn off notifications \n 1 - once an hour \n 2 - every 2 hours \n 3 - every 3 hours", preferredStyle: .alert)
                    
                    alert.addTextField{(number) in
                        number.text = ""
                        number.placeholder = "0 / 1 / 2 / 3 ?"
                    }
                    
                
                let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { [ weak alert] (_) in
                        let number = alert?.textFields![0]
                        let timesNew = number?.text
                        
                        
                        
                        if timesNew == nil {
                            let error = UIAlertController(title: "Empty field", message: "Please enter your data to field", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                                print("Ok button tapped")
                            })
                            
                            error.addAction(ok)
                            self.present(error, animated: true, completion: nil)
                        }
                        else if(timesNew == "0") {
                            self.buttonSwitchCheck = false
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                       
                        }
                        else{
                            let timeText = Int(String(timesNew ?? ""))
                            self.timesAday = timeText ?? 1
                            self.applicationDidBackground()
                            self.buttonSwitchCheck = true
                        }
                        
                    })
                    
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                        print("Canelled")
                    })
                    
                    alert.addAction(confirmAction)
                    alert.addAction(cancelAction)
                    
                    present(alert, animated: true, completion: nil)
    }
    
    // MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        
        let alert = UIAlertController(title: "NEW WORD", message: "", preferredStyle: .alert)
        
        alert.addTextField{(word) in
            word.text = ""
            word.placeholder = "Word"
        }
        
        alert.addTextField(configurationHandler: {(meaning) in
            meaning.text = ""
            meaning.placeholder = "Meaning"
            
        })
        
        
        let confirmAction = UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let wordField = alert?.textFields![0]
            let meaningField = alert?.textFields![1]
            
            
            let word = wordField?.text
            let meaning = meaningField?.text
            
            if word == "" || meaning == "" {
                let error = UIAlertController(title: "Empty field", message: "Please enter your data to field", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    print("Ok button tapped")
                })
                
                error.addAction(ok)
                self.present(error, animated: true, completion: nil)
            }
            else {
                let newItem = Item()
                newItem.word = word ?? ""
                newItem.meaning = meaning ?? ""
                self.itemArray.append(newItem)
                self.newArray.append(newItem.word + ": " + newItem.meaning)
                self.saveItems()
            }
            
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            print("Canelled")
        })
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK - notifications
    

    
    @IBAction func notificationsONnew(_ sender: UISwitch) {
        if sender.isOn {
            applicationDidBackground()
            buttonSwitchCheck = true
        }
        else {
            buttonSwitchCheck = false
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    
    
//    func applicationDidEnterBackground1() {
//
//            var index = 0
//
//           backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
//
//               UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
//
//           })
//
//           _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
//               if(self.buttonSwitchCheck){
//                   print(index)
//                   self.setNotification(
//                       identifier: String(index),
//                       text: self.newArray[index])
//                   index += 1
//                   if (index == self.newArray.count) {
//                       index = 0
//                   }
//                                  }
//               else {
//                   timer.invalidate()
//               }
//           }
//
//        }

    
    func applicationDidBackground() {
        var times = 12
        var i = 0
        var index = 0
        var newHour = 0
        var finalTimes = times/timesAday
        while i < finalTimes{
            while index < newArray.count{
                setNotification(identifier: newArray[index], text: newArray[index], hours: newHour)
                index += 1
            }
            i += 1
            index = 0
            newHour += timesAday
        }
    }
        

        
    func setNotification (identifier : String, text: String, hours: Int){
        
        let content = UNMutableNotificationContent()
        content.title = "Time to study!"
        content.body = text
        content.sound = UNNotificationSound.default
        content.badge = 1

        print("times \(timesAday)")
        
        var dateInfo = DateComponents()
        dateInfo.hour = 10 + hours
        dateInfo.minute = 00
                
        print("date")
        print("hour \(dateInfo.hour)")
        print("minute \(dateInfo.minute)")
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.hour, from: date)
        let newIdentifier = identifier + String(day) + String(month) + String(hour) + String(minute) + String(hours)
               
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
        let request = UNNotificationRequest(identifier: newIdentifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
                   print(identifier)
        center.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
                       }else{
                           print("send!!")
            }
        }
        
}

        
        


    //https://forum.swiftbook.ru/t/kak-ustanovit-vremennoj-interval-dostavki-uvedomlenij/10554
    
    // MARK - save changes

    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        self.tableView.reloadData()
    }
    
    
    
    
    func loadItems(){
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }
    

    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView( _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            itemArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        saveItems()
    }
}

