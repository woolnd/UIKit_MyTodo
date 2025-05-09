//
//  MemoDetailViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/9/25.
//

import UIKit

class MemoDetailViewController: UIViewController {
    var memoID: String?
    var memoTitle: String?
    var memoContent: String?
    var memoDate: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = memoTitle
        dateLabel.text = memoDate
        contentLabel.text = memoContent
    }

}
