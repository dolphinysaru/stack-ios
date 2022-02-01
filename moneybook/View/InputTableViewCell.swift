//
//  InputTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/24.
//

import UIKit

class InputTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var emojiTextField: EmojiTextField!
    var isEmoji = false
    var didChangeText: ((UITextField, String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.setupCornerRadius()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChangeNotification),
            name: UITextField.textDidChangeNotification,
            object: nil
        )
    }
    
    @objc func textDidChangeNotification() {
        if isEmoji {
            if emojiTextField.textInputMode == nil {
                if let text = emojiTextField.text?.prefix(1) {
                    emojiTextField.text = String(text)
                }
            } else {
                if let text = emojiTextField.text?.prefix(1) {
                    if String(text).isSingleEmoji {
                        emojiTextField.text = String(text)
                    } else {
                        emojiTextField.text = nil
                    }
                }
            }
            didChangeText?(emojiTextField, emojiTextField.text)
        } else {
            didChangeText?(textField, textField.text)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(isEmojiInput: Bool) {
        if isEmojiInput {
            textField.isHidden = true
            emojiTextField.isHidden = false
            
            emojiTextField.placeholder = "emoji_placeholder".localized()
        } else {
            textField.isHidden = false
            emojiTextField.isHidden = true
            
            textField.placeholder = "name_placeholder".localized()
        }
        
        isEmoji = isEmojiInput
    }
}

class EmojiTextField: UITextField {
    // required for iOS 13
    override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}
