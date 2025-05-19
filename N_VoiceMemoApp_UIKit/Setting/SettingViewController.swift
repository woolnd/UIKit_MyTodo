//
//  SettingViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/19/25.
//

import UIKit
import Combine

class SettingViewController: UIViewController {

    @IBOutlet weak var todoCount: UILabel!
    @IBOutlet weak var memoCount: UILabel!
    @IBOutlet weak var recordingCount: UILabel!
    
    private var viewModel: SettingViewModel = SettingViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindingViewModel()
        viewModel.process(.loadData)
    }
    
    private func bindingViewModel() {
        viewModel.state.$viewModels.receive(on: DispatchQueue.main)
            .sink { [weak self]_ in
                self?.applyUI()
            }.store(in: &cancellables)
    }
    
    private func applyUI() {
        todoCount.text = "\(viewModel.state.viewModels.todoCount)"
        memoCount.text = "\(viewModel.state.viewModels.memoCount)"
        recordingCount.text = "\(viewModel.state.viewModels.recordingCount)"
    }
    
}
