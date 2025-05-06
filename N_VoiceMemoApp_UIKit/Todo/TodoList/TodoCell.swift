//
//  TodoCell.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/3/25.
//

import UIKit

struct TodoCellViewModel: Hashable {
    let id: String
    let title: String
    let date: String
    let time: String
    var isCompleted: Bool
}

final class TodoCell: UICollectionViewCell {
    static let reusableId: String = "TodoCell"
    
    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var todoDateLabel: UILabel!
    @IBOutlet weak var todoIsCompletedButton: UIButton!
    
    var onToggleComplete: (() -> Void)?  // ✅ 버튼 클릭 콜백 추가
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        isUserInteractionEnabled = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 💡 재사용 전 layer 초기화 확실히
        contentView.layer.sublayers?.removeAll(where: {
            $0.name == "topBorder" || $0.name == "bottomBorder"
        })
    }
    
    func configure(_ viewModel: TodoCellViewModel, _ isFirst: Bool = false, _ isLast: Bool = false) {
        todoTitleLabel.text = viewModel.title
        todoDateLabel.text = "\(viewModel.date) - \(viewModel.time)"
        
        todoIsCompletedButton.setImage(viewModel.isCompleted ? .checkOn : .checkOff, for: .normal)
        
        // ✅ topBorder는 항상 첫 셀만
        if isFirst {
            let topBorder = CALayer()
            topBorder.name = "topBorder"
            topBorder.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
            topBorder.backgroundColor = UIColor.systemGray5.cgColor
            contentView.layer.addSublayer(topBorder)
        }
        
        // ✅ bottomBorder는 항상 추가 (단 중복 X)
        let bottomBorder = CALayer()
        bottomBorder.name = "bottomBorder"
        bottomBorder.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        bottomBorder.backgroundColor = UIColor.systemGray5.cgColor
        contentView.layer.addSublayer(bottomBorder)
        
        
        // 취소선 처리
        if viewModel.isCompleted {
            todoTitleLabel.attributedText = NSAttributedString(
                string: viewModel.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            todoIsCompletedButton.setImage(.checkOn, for: .normal)
            todoTitleLabel.textColor = UIColor.iconOn
        } else {
            todoTitleLabel.attributedText = NSAttributedString(string: viewModel.title)
            todoIsCompletedButton.setImage(.checkOff, for: .normal)
            todoTitleLabel.textColor = UIColor.bk
        }
    }
    
    @IBAction func isCompleteButtonTapped(_ sender: Any) {
        onToggleComplete?()
    }
}

extension TodoCell{
    static func todoLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}
