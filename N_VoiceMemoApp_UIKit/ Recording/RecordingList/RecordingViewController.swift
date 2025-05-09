//
//  RecordingViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/10/25.
//

import UIKit
import Combine

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var recordingListView: UIView!
    @IBOutlet weak var recordingButton: UIButton!
    
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    private lazy var dataSource: DataSource = setDataSource()
    private var viewModel: RecordingViewModel = RecordingViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private var currentSection: [Section] {
        dataSource.snapshot().sectionIdentifiers as [Section]
    }
    
    private enum Section {
        case recordingList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindingViewModel()
        collectionView.collectionViewLayout = layout()
        viewModel.process(.loadData)
        
        
    }
    
    private func bindingViewModel() {
        viewModel.state.$viewModels.receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }.store(in: &cancellables)
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] section, _ in
            switch self?.currentSection[section] {
            case .recordingList:
                return RecordingCell.recordingLayout()
            case .none:
                return nil
            }
        }
    }
    
    private func setDataSource() -> DataSource {
        let dataSource: DataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, viewModel in
            
            switch self?.currentSection[indexPath.section]{
            case .recordingList:
                return self?.recordingCell(collectionView, indexPath, viewModel)
            case .none:
                return .init()
            }
        }
        return dataSource
    }
    
    private func applySnapshot() {
        var snapshot: Snapshot = Snapshot()
        
        let recordingViewModels = viewModel.state.viewModels.recordingViewModels
        
        if recordingViewModels.isEmpty {
            hidden(true)
        } else {
            hidden(false)
            snapshot.appendSections([.recordingList])
            snapshot.appendItems(recordingViewModels, toSection: .recordingList)
            dataSource.apply(snapshot) { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func recordingCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ viewModel: AnyHashable) -> UICollectionViewCell {
        
        guard let viewModel = viewModel as? RecordingCellViewModel else {
            return .init()
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordingCell.reusableId, for: indexPath) as? RecordingCell
        else {
            return UICollectionViewCell()
        }
        
        let itemCount = dataSource.snapshot().itemIdentifiers(inSection: .recordingList).count
        let isFirst = indexPath.item == 0
        let isLast = indexPath.item == itemCount - 1
        
        cell.configure(viewModel, isFirst, isLast)
        
        return cell
    }
    
    private func hidden(_ isHidden: Bool){
        if isHidden {
            recordingListView.alpha = 0
        } else {
            recordingListView.alpha = 1
        }
    }
    
    
    @IBAction func recordingCreateButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "RecordingCreate", bundle: nil)
        guard let recordingCreateVC = storyboard.instantiateViewController(withIdentifier: "RecordingCreateViewController") as? RecordingCreateViewController else { return }
        
        //TodoCreateViewController를 NavigationController로 감싸서 present 자동으로 < 뒤로가기 버튼이 생김
        let nav = UINavigationController(rootViewController: recordingCreateVC)
        nav.modalPresentationStyle = .fullScreen
        
        // ✅ 콜백으로 데이터 다시 불러오기
        recordingCreateVC.onRecordingCreated = { [weak self] in
            self?.viewModel.process(.loadData)
        }
        self.present(nav, animated: true)
    }
}


