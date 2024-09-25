import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import SwiftUI


class TaskViewModel: ObservableObject {
    @Published var tasks: [String] = []  // Stores the task names
    private var db = Firestore.firestore()

    // Fetch a larger set of tasks, then randomly select 3
    func fetchThreeRandomTasks() {
        db.collection("tasks").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching tasks: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No tasks found")
                return
            }
            
            // Extract all task names from the documents
            let allTasks = documents.compactMap { document -> String? in
                let data = document.data()
                return data["name"] as? String  // Assuming 'name' is the task's name field
            }
            
            // Shuffle the tasks to randomize them and select the first 3
            DispatchQueue.main.async {
                self.tasks = Array(allTasks.shuffled().prefix(3))  // Take 3 random tasks
            }
        }
    }
}
