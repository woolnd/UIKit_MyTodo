//
//  MemoCell.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/6/25.
//

import UIKit

struct MemoCellViewModel: Hashable {
    let id: String
    let title: String
    let content: String
    let date: String
}



class MemoCell: UICollectionViewCell {
    static let reusableId: String = "MemoCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
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
    
    func configure(_ viewModel: MemoCellViewModel, _ isFirst: Bool = false, _ isLast: Bool = false) {
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.date
        
        
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
    }
}

extension MemoCell{
    static func memoLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}
