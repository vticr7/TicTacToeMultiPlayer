

import UIKit
import Firebase
class ViewController: UIViewController {
    var opponentEmail: String?
    @IBOutlet weak var txtPlayerEmail: UITextField!
    var UserUID:String?
     var UserEmail:String?
    @IBOutlet weak var bu9: UIButton!
    
    
    @IBOutlet weak var bu8: UIButton!
    
    
    @IBOutlet weak var bu7: UIButton!
    
    @IBOutlet weak var bu6: UIButton!
    
    @IBOutlet weak var bu5: UIButton!
    
    @IBOutlet weak var bu4: UIButton!
    
    @IBOutlet weak var bu3: UIButton!
    
    @IBOutlet weak var bu2: UIButton!
    
    @IBOutlet weak var bu1: UIButton!
    
    var ref = DatabaseReference.init()
    
    override func viewDidLoad() {
        self.ref = Database.database().reference()
        super.viewDidLoad()
        incommingRequests()
        // Do any additional setup after loading the view, typically from a nib.
    }

   
    @IBAction func buSeletEvent(_ sender: Any) {
        let buSelect =  sender as! UIButton
        
         self.ref.child("tictactoe").child("PlayingOnline").child(sessionID!).child("\(buSelect.tag)").setValue( UserEmail!)
      // playGame(buSelect: buSelect)
        
    }
    
    var ActivePlayer =  1
    var player1 = [Int]()
    var player2 = [Int]()
    func playGame(buSelect:UIButton){
        
        if ActivePlayer == 1 {
            buSelect.setTitle("X", for: UIControlState.normal)
            buSelect.backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 1, alpha: 1)
            player1.append(buSelect.tag)
            ActivePlayer =  2
            //print(player1)
           // AutoPlay()
        }else{
             buSelect.backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 1, alpha: 1)
            buSelect.setTitle("O", for: UIControlState.normal)
             player2.append(buSelect.tag)
            ActivePlayer =  1
            //print(player2)
            
        }
        buSelect.isEnabled = false
        findWinner()
        
    }
    
    func findWinner() {
        // Initialize winner as nil
        var winner: String? = nil
        
        // Winning combinations
        let winConditions = [
            [1, 2, 3], [4, 5, 6], [7, 8, 9], // Rows
            [1, 4, 7], [2, 5, 8], [3, 6, 9], // Columns
            [1, 5, 9], [3, 5, 7]            // Diagonals
        ]
        
        // Check for winner
        for condition in winConditions {
            if condition.allSatisfy(player1.contains) {
                winner = UserEmail
                break
            } else if condition.allSatisfy(player2.contains) {
                winner = opponentEmail
                break
            }
        }
        
        // Display the winner if there is one
        if let winnerEmail = winner {
            // Create the alert
            let msg = "\(winnerEmail) is the winner!"
            let alert = UIAlertController(title: "Game Over", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                // Add any action you want to perform after the alert is dismissed
                // For example, you might want to reset the game to its initial state
            }))
            
            // Present the alert
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    func AutoPlay(cellID:Int){
        var buSelect:UIButton?
        switch cellID {
        case 1:
            buSelect = bu1
        case 2:
            buSelect = bu2
        case 3:
            buSelect = bu3
        case 4:
            buSelect = bu4
        case 5:
            buSelect = bu5
        case 6:
            buSelect = bu6
        case 7:
            buSelect = bu7
        case 8:
            buSelect = bu8
        case 9:
            buSelect = bu9
        default:
                buSelect = bu1
        }
        playGame(buSelect: buSelect!)
    }
    
    
    var playerSymbol:String?
    @IBAction func buRequest(_ sender: Any) {
        self.ref.child("tictactoe").child("users").child(SplitEmail(email: txtPlayerEmail.text!)).child("Request").childByAutoId().setValue(UserEmail!)
        playerSymbol = "X"
        opponentEmail = txtPlayerEmail.text // Store the opponent's email
        playOnline(sessionID: "\(SplitEmail(email: UserEmail!)) \(SplitEmail(email: txtPlayerEmail.text!))")
    }

    @IBAction func buAccept(_ sender: Any) {
        self.ref.child("tictactoe").child("users").child(SplitEmail(email: txtPlayerEmail.text!)).child("Request").childByAutoId().setValue(UserEmail!)
        playerSymbol = "O"
        opponentEmail = txtPlayerEmail.text // Store the opponent's email
        playOnline(sessionID: "\(SplitEmail(email: txtPlayerEmail.text!)) \(SplitEmail(email: UserEmail!))")
    }
    
    func SplitEmail(email:String)->String {
        let arrayEmail = email.split(separator: "@")
        return  String(arrayEmail[0])
    }
    
    
    
    func incommingRequests(){
        self.ref.child("tictactoe").child("users").child(SplitEmail(email:UserEmail!)).child("Request").observe(.value, with: {
            (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                for snap in snapshot {
                    
                    if let playerRequest = snap.value as? String {
                        self.txtPlayerEmail.text = playerRequest
                        self.ref.child("tictactoe").child("users").child(self.SplitEmail(email:self.UserEmail!)).child("Request").setValue(self.UserUID!)
                        
                        
                     }
                 }
            
            }
          })
    }
    
    var sessionID:String?
    func playOnline(sessionID:String){
       self.sessionID = sessionID
         self.ref.child("tictactoe").child("PlayingOnline").child(sessionID).removeValue()
        self.ref.child("tictactoe").child("PlayingOnline").child(sessionID).observe(.value, with: {
            (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.player1.removeAll()
                self.player2.removeAll()
                for snap in snapshot {
                    
                    if let playerEmail = snap.value as? String {
                        let keyCellID = snap.key as? String
                        if playerEmail == self.UserEmail! {
                            self.ActivePlayer = self.playerSymbol! == "X" ? 1: 2
                        }else {
                            self.ActivePlayer = self.playerSymbol! == "X" ? 2: 1
                        }
                        self.AutoPlay(cellID: Int(keyCellID!)!)
                    }
                }
                
            }
        })
    }
}

