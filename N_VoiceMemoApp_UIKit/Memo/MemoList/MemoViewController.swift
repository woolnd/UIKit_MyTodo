//
//  MemoViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/6/25.
//

import UIKit
import Combine

class MemoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var memoListView: UIView!
    @IBOutlet weak var memoCreateButton: UIButton!
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    private lazy var dataSource: DataSource = setDataSource()
    private var viewModel: MemoViewModel = MemoViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private var currentSection: [Section] {
        dataSource.snapshot().sectionIdentifiers as [Section]
    }
    
    private enum Section {
        case memoList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindingViewModel()
        viewModel.process(.loadData)
        collectionView.collectionViewLayout = layout()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.delegate = self
    }
    
    private func bindingViewModel() {
        viewModel.state.$viewModels.receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &cancellables)
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout{ [weak self] section, _ in
            switch self?.currentSection[section] {
            case .memoList:
                return MemoCell.memoLayout()
            case .none:
                return nil
            }
        }
    }
    
    private func setDataSource() -> DataSource {
        let dataSource: DataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, viewModel in
            
            switch self?.currentSection[indexPath.section] {
            case .memoList:
                return self?.memoCell(collectionView, indexPath, viewModel)
            case .none:
                return .init()
            }
        }
        
        return dataSource
    }
    
    private func applySnapshot() {
        var snapshot: Snapshot = Snapshot()
        
        let memoViewModels = viewModel.state.viewModels.memoViewModels
        
        if memoViewModels.isEmpty {
            hidden(true)
        } else {
            hidden(false)
            snapshot.appendSections([.memoList])
            snapshot.appendItems(memoViewModels, toSection: .memoList)
            dataSource.apply(snapshot) { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func memoCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ viewModel: AnyHashable) -> UICollectionViewCell {
        
        guard let viewModel = viewModel as? MemoCellViewModel else {
            return .init()
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoCell.reusableId, for: indexPath) as? MemoCell
        else {
            return UICollectionViewCell()
        }
        
        let itemCount = dataSource.snapshot().itemIdentifiers(inSection: .memoList).count
        let isFirst = indexPath.item == 0
        let isLast = indexPath.item == itemCount - 1
        
        cell.configure(viewModel, isFirst, isLast)
        
        return cell
    }
    
    private func hidden(_ isHidden: Bool){
        if isHidden {
            memoListView.alpha = 0
            subTitleLabel.alpha = 0
        } else {
            memoListView.alpha = 1
            subTitleLabel.alpha = 1
        }
    }
    
    @IBAction func memoCreateButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MemoCreate", bundle: nil)
        guard let memoCreateVC = storyboard.instantiateViewController(withIdentifier: "MemoCreateViewController") as? MemoCreateViewController else { return }
        
        //TodoCreateViewController를 NavigationController로 감싸서 present 자동으로 < 뒤로가기 버튼이 생김
        let nav = UINavigationController(rootViewController: memoCreateVC)
        nav.modalPresentationStyle = .fullScreen
        
        // ✅ 콜백으로 데이터 다시 불러오기
        memoCreateVC.onMemoCreated = { [weak self] in
            self?.viewModel.process(.loadData)
        }
        self.present(nav, animated: true)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: location) {
            let cellViewModel = viewModel.state.viewModels.memoViewModels[indexPath.row]
            
            let alert = UIAlertController(title: "삭제하시겠습니까?",
                                          message: "\"\(cellViewModel.title)\" 메모를 삭제할까요?",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
                self.viewModel.process(.deleteMemo(cellViewModel.id))
                self.viewModel.process(.loadData)
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
}

extension MemoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedMemo = viewModel.state.viewModels.memoViewModels[indexPath.row]
        
        let storyboard = UIStoryboard(name: "MemoDetail", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "MemoDetailViewController") as! MemoDetailViewController
        
        detailVC.memoTitle = selectedMemo.title
        detailVC.memoID = selectedMemo.id
        detailVC.memoContent = selectedMemo.content
        detailVC.memoDate = selectedMemo.date
        
        present(detailVC, animated: true)
    }
}
