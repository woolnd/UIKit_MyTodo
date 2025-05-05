//
//  TodoViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/3/25.
//

import UIKit
import Combine

class TodoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var todoCreateButton: UIButton!
    @IBOutlet weak var emptyDescriptionView: UIView!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    private lazy var dataSource: DataSource = setDataSource()
    private var viewModel: TodoViewModel = TodoViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private var currentSection: [Section] {
        dataSource.snapshot().sectionIdentifiers as [Section]
    }
    
    
    private enum Section: Int {
        case todoList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindingViewModel()
        collectionView.collectionViewLayout = layout()
        viewModel.process(.loadData)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
    }
    
    private func bindingViewModel() {
        viewModel.state.$viewModels.receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapShot()
            }.store(in: &cancellables)
    }
    
    private func layout() -> UICollectionViewCompositionalLayout{
        UICollectionViewCompositionalLayout{ [weak self] section, _ in
            switch self?.currentSection[section] {
            case .todoList:
                return TodoCell.todoLayout()
            case .none:
                return nil
            }
        }
    }
    
    private func setDataSource() -> DataSource {
        let dataSource: DataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, viewModel in
            switch self?.currentSection[indexPath.section] {
            case .todoList:
                return self?.todoCell(collectionView, indexPath, viewModel)
            case .none:
                return .init()
            }
        }
        
        return dataSource
    }
    
    private func applySnapShot() {
        var snapShot: Snapshot = Snapshot()
        
        let todoViewModels = viewModel.state.viewModels.todoViewModels 
        
        // ✅ 데이터가 없는 경우
        if todoViewModels.isEmpty {
            hidden(true)
        } else {
            hidden(false)
            snapShot.appendSections([.todoList])
            snapShot.appendItems(todoViewModels, toSection: .todoList)
            dataSource.apply(snapShot) { [weak self] in
                        // 💡 셀이 갱신되었을 때 강제로 다시 레이아웃을 트리거
                        self?.collectionView.reloadData()
                    }
        }
    }
    
    private func todoCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ viewModel: AnyHashable) -> UICollectionViewCell {
        guard let viewModel = viewModel as? TodoCellViewModel else { return .init() }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoCell.reusableId, for: indexPath) as? TodoCell else { return UICollectionViewCell() }
        
        // 섹션의 전체 아이템 수 가져오기
        let itemCount = dataSource.snapshot().itemIdentifiers(inSection: .todoList).count
        let isFirst = indexPath.item == 0
        let isLast = indexPath.item == itemCount - 1
        
        // ✅ 수정된 configure 적용
        cell.configure(viewModel, isFirst, isLast)
        cell.onToggleComplete = { [weak self] in
            guard let self = self else { return }
            let todoID = viewModel.id
            self.viewModel.toggleComplete(id: todoID)
        }
        
        return cell
    }
    
    private func hidden(_ isHidden: Bool){
        if isHidden {
            emptyDescriptionView.alpha = 0
            subTitleLabel.alpha = 0
        } else {
            emptyDescriptionView.alpha = 1
            subTitleLabel.alpha = 1
        }
    }
    
    @IBAction func todoCreateButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TodoCreate", bundle: nil)
        guard let todoCreateVC = storyboard.instantiateViewController(withIdentifier: "TodoCreateViewController") as? TodoCreateViewController else { return }
        
        //TodoCreateViewController를 NavigationController로 감싸서 present 자동으로 < 뒤로가기 버튼이 생김
        let nav = UINavigationController(rootViewController: todoCreateVC)
        nav.modalPresentationStyle = .fullScreen
        
        // ✅ 콜백으로 데이터 다시 불러오기
        todoCreateVC.onTodoCreated = { [weak self] in
            self?.viewModel.process(.loadData)
        }
        self.present(nav, animated: true)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let location = gesture.location(in: collectionView)

        if let indexPath = collectionView.indexPathForItem(at: location) {
            let cellViewModel = viewModel.state.viewModels.todoViewModels[indexPath.row]

            let alert = UIAlertController(title: "삭제하시겠습니까?",
                                          message: "\"\(cellViewModel.title)\" 할 일을 삭제할까요?",
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
                self.viewModel.deleteTodo(id: cellViewModel.id)
                self.viewModel.process(.loadData)
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))

            self.present(alert, animated: true)
        }
    }
}


#Preview{
    UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
}
