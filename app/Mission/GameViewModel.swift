//
//  GameViewModel.swift
//  Mission
//
//  Created by dolly.belcher on 26/09/2024.
//

import FirebaseFirestore
import Combine

class GameViewModel: ObservableObject {
    @Published var gameCode: String = ""          // Game code for the session
    @Published var players: [String] = []         // List of players in the game
    private let db = Firestore.firestore()

    // Create a game and generate a unique game code
    func createGame() {
        // Generate a random 6-character game code
        let generatedCode = UUID().uuidString.prefix(6).uppercased()
        
        // Create a new game document in Firestore with an empty players array
        let gameData: [String: Any] = ["players": [], "tasks": []]
        
        db.collection("games").document(String(generatedCode)).setData(gameData) { error in
            if let error = error {
                print("Error creating game: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.gameCode = String(generatedCode)  // Store the generated game code
                }
            }
        }
    }

    // Join a game by adding a player to the players array
    func joinGame(with code: String, playerName: String) {
        let gameRef = db.collection("games").document(code)
        
        gameRef.getDocument { document, error in
            if let document = document, document.exists {
                var players = document.data()?["players"] as? [String] ?? []
                
                // Check if the player is already in the game
                if !players.contains(playerName) {
                    players.append(playerName)
                    
                    // Update Firestore with the new player added to the players array
                    gameRef.updateData(["players": players]) { error in
                        if let error = error {
                            print("Error updating game with new player: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                self.players = players
                            }
                        }
                    }
                } else {
                    print("Player already in the game.")
                }
            } else {
                print("No such game found!")
            }
        }
    }

    // Listen for real-time updates to the players array in Firestore
    func listenForPlayersUpdates(gameCode: String) {
        db.collection("games").document(gameCode).addSnapshotListener { documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                let players = document.data()?["players"] as? [String] ?? []
                DispatchQueue.main.async {
                    self.players = players
                }
            }
        }
    }
}
