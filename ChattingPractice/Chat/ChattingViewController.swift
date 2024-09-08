//
//  ViewController.swift
//  ChattingPractice
//
//  Created by jaegu park on 9/8/24.
//

import UIKit
import SocketIO

class ChattingViewController: UIViewController , UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var messageTF: UITextField!
    
    @IBOutlet weak var chatTableView: UITableView!
    
    var nickname: String!
    
    var chatMessage = [[String: AnyObject]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        //제스쳐 이벤트
        let swipGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipGestureRecognizer.direction = .down
        swipGestureRecognizer.delegate = self
        view.addGestureRecognizer(swipGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configTableView()
        
        messageTF.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //새로운 메시지를 받기 위한 로직
        SocketIOManager.shared.getChatMessage { (messageInfo) in
            DispatchQueue.main.async {
                self.chatMessage.append(messageInfo)
                self.chatTableView.reloadData()
                //self.scrollToBottom()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SocketIOManager.shared.closeConnection()
    }
    
    func configTableView() {
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        chatTableView.estimatedRowHeight = 90.0            //예상되는 높이 값
        chatTableView.rowHeight = UITableView.automaticDimension //각 행 높이 다르게
        chatTableView.tableFooterView = UIView(frame: .zero)
    }
    
    @IBAction func send_Tapped(_ sender: Any) {
        if messageTF.text!.count > 0 {
            //메시지 서버에 발송
            SocketIOManager.shared.sendMessage(message: self.messageTF.text!, withNickname: nickname)
            messageTF.text = ""
            messageTF.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chat_TableViewCell", for: indexPath) as! ChatTableViewCell
                
        let curChatMsg = chatMessage[indexPath.row]
        let senderNickName = curChatMsg["nickname"] as! String
        let msg = curChatMsg["message"] as! String
        
        if senderNickName == nickname {
            cell.chatLabel.textAlignment = .right
        }
                
        cell.chatLabel.text = msg
                
        return cell
    }
    
    @objc func handleKeyboardDidShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo{
            
            if let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                //conBottomEditor.constant = keyboardFrame.size.height
                //view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyboardDidHideNotification(notification: NSNotification) {
        //conBottomEditor.constant = 5
        //view.layoutIfNeeded()
    }
        
        //키보드 내림 제스쳐 이벤트
    @objc func dismissKeyboard() {
        if messageTF.isFirstResponder{
            messageTF.resignFirstResponder()
            SocketIOManager.shared.sendStopTypingMessage(nickName: nickname)
        }
    }
    
    private func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        SocketIOManager.shared.sendStartTypingMessage(nickName: nickname)
        
        return true
    }
        
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
