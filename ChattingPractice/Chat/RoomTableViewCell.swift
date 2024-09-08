//
//  RoomTableViewCell.swift
//  ChattingPractice
//
//  Created by jaegu park on 9/8/24.
//

import UIKit

class RoomTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        separatorInset = .zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
        layoutIfNeeded()
                
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
