//
//  RoomViewController.swift
//  ChattingPractice
//
//  Created by jaegu park on 9/8/24.
//

import UIKit

class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var RoomList: UITableView!
    
    var rooms = [[String: AnyObject]]()
    
    var nickname: String!
    
    var configurationOK = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !configurationOK{
            configureTableView()
            configurationOK = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if nickname == nil {
            askForNickname()
        }
    }
    
    func configureTableView() {
        self.RoomList.delegate = self
        self.RoomList.dataSource = self
        self.RoomList.isHidden = true
        RoomList.tableFooterView = UIView(frame: .zero)
    }
    
    func askForNickname() {
        let alertController = UIAlertController(title: "SocketChat", message: "닉네임을 입력하세요:", preferredStyle: .alert)
        
        alertController.addTextField { (tf) in
            tf.placeholder = "nicName"
        }
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let textField = alertController.textFields![0]
            if textField.text?.count == 0 {
                //팝업창에 아무값을 입력안했으면 다시 호출
                self.askForNickname()
            } else{
                
                //유저 닉네임
                self.nickname = textField.text
                
                //소켓 연결 + 유저 닉네임
                SocketIOManager.shared.connectToServerWithNickname(nickname: self.nickname) { (userList) in
                    
                    //테이블뷰 DATA SOURCE 갱신
                    DispatchQueue.main.async {
                        if userList.count != 0{
                            self.rooms = userList
                            self.RoomList.reloadData()
                            self.RoomList.isHidden = false
                        }
                    }
                }
            }
        }
        
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func exit_Tapped(_ sender: Any) {
        SocketIOManager.shared.exitChatWithNickname(nickname: nickname) {
            
            DispatchQueue.main.async {
                self.nickname = nil
                self.rooms.removeAll()
                self.RoomList.isHidden = true
                self.askForNickname()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifire = segue.identifier {
            if identifire == "idSegueJoinChat" {
                let chatViewController = segue.destination as! ChattingViewController
                //채팅뷰 컨트롤러에 닉네임 할당
                chatViewController.nickname = self.nickname
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    //MARK:- cell 구성 - 유저이름, 연결상태
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Room_TableViewCell", for: indexPath) as! RoomTableViewCell
        
        
        cell.textLabel?.text = rooms[indexPath.row]["nickname"] as? String
        cell.detailTextLabel?.text = (rooms[indexPath.row]["isConnected"] as! Bool) ? "online" : "offline"
        cell.detailTextLabel?.textColor = (rooms[indexPath.row]["isConnected"] as! Bool) ? .green : .red
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
