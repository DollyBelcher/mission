import FirebaseFirestore
import FirebaseDatabase

class FirebaseHelper {

    static let db = Firestore.firestore()  // Firestore instance
    static let realtimeDB = Database.database()  // Realtime Database instance

    // Function to assign random tasks to the player and save to Realtime Database
    static func assignRandomTasks(for player: String, in gameCode: String, completion: @escaping (Bool) -> Void) {
        let tasksRef = db.collection("tasks")  // Firestore collection for tasks
        let playerRef = realtimeDB.reference().child("games").child(gameCode).child("players").child(player)
        let assignedTasksRef = realtimeDB.reference().child("games").child(gameCode).child("assignedTasks")

        // Step 1: Fetch tasks from Firestore
        tasksRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching tasks from Firestore: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let documents = snapshot?.documents else {
                print("No tasks found in Firestore.")
                completion(false)
                return
            }

            // Extract the "name" field from each document
            let allTasks = documents.compactMap { $0["name"] as? String }
            print("Tasks fetched from Firestore: \(allTasks)")

            if allTasks.isEmpty {
                print("No tasks available in Firestore.")
                completion(false)
                return
            }

            // Step 2: Fetch already assigned tasks from the database
            assignedTasksRef.observeSingleEvent(of: .value) { snapshot in
                var assignedTasks = [String]()
                if let assignedDict = snapshot.value as? [String: String] {
                    assignedTasks = Array(assignedDict.values)
                }

                // Step 3: Filter out the already assigned tasks
                let availableTasks = allTasks.filter { !assignedTasks.contains($0) }
                print("Available tasks after filtering: \(availableTasks)")

                // Ensure there are enough tasks remaining
                if availableTasks.count < 3 {
                    print("Not enough tasks available for assignment.")
                    completion(false)
                    return
                }

                // Shuffle the remaining tasks and select the first 3
                let shuffledTasks = availableTasks.shuffled()
                let playerTasks = Array(shuffledTasks.prefix(3))

                print("Shuffled tasks for \(player): \(playerTasks)")

                // Step 4: Save the player's tasks
                playerRef.child("tasks").setValue(playerTasks) { error, _ in
                    if let error = error {
                        print("Error saving tasks to Realtime Database: \(error.localizedDescription)")
                        completion(false)
                        return
                    }

                    // Step 5: Save the assigned tasks to the global list
                    var updates = [String: Any]()
                    for task in playerTasks {
                        updates[task] = player  // Track which player got which task
                    }
                    assignedTasksRef.updateChildValues(updates) { error, _ in
                        if let error = error {
                            print("Error saving assigned tasks: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Tasks successfully assigned and saved for \(player): \(playerTasks)")
                            completion(true)
                        }
                    }
                }
            }
        }
    }
}
