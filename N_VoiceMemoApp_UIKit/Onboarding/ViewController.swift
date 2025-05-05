//
//  ViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/1/25.
//

import UIKit

struct titleModel: Hashable {
    var title: String
    var subTitle: String
}

extension titleModel {
    static let mock: [titleModel] = [
        titleModel(title: "오늘의 할일", subTitle: "To do list로 언제 어디서든 해야할일을 한눈에"),
        titleModel(title: "똑똑한 나만의 기록장", subTitle: "메모장으로 생각나는 기록은 언제든지"),
        titleModel(title: "하나라도 놓치지 않도록", subTitle: "음성메모 기능으로 놓치고 싶지않은 기록까지"),
        titleModel(title: "정확한 시간의 경과", subTitle: "타이머 기능으로 원하는 시간을 확인")
    ]
}

class ViewController: UIViewController {
    
    @IBOutlet weak var onboardPageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var onboardPageViewController: OnboardPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleModel.mock[0].title
        subTitleLabel.text = titleModel.mock[0].subTitle
        
        onboardPageControl.pageIndicatorTintColor = UIColor.gray2
        onboardPageControl.currentPageIndicatorTintColor = UIColor.key
        
        button.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let desinationViewController = segue.destination as? OnboardPageViewController {
            onboardPageViewController = desinationViewController
            onboardPageViewController.onboardDelegate = self
        }
    }
    
    func updatePageControlUI(currentPageIndex: Int) {
        onboardPageControl.pageIndicatorTintColor = UIColor.gray2
        onboardPageControl.currentPageIndicatorTintColor = UIColor.key
    }
    
    func updateLabels(for index: Int) {
        guard index < titleModel.mock.count else { return }
        titleLabel.text = titleModel.mock[index].title
        subTitleLabel.text = titleModel.mock[index].subTitle
    }
    
    func visibleButton(index: Int){
        if index == 3 {
            button.isHidden = false
            button.semanticContentAttribute = .forceRightToLeft //버튼 image 강제로 오른쪽으로 옮기기
            button.tintColor = .key
        } else {
            button.isHidden = true
        }
    }
    
    @IBAction func pageControlTapped(_ sender: Any) {
        let currentPageIndex = onboardPageControl.currentPage
        onboardPageViewController.goToPage(index: currentPageIndex)
        updatePageControlUI(currentPageIndex: onboardPageControl.currentPage)
        updateLabels(for: onboardPageControl.currentPage)
        visibleButton(index: onboardPageControl.currentPage)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "MainViewController") as! MainViewController
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}


extension ViewController: OnboardPageControlDelegate{
    func numberOfPage(numberOfPage: Int) {
        onboardPageControl.numberOfPages = numberOfPage
    }
    
    func pageChangedTo(index: Int) {
        updatePageControlUI(currentPageIndex: index)
        onboardPageControl.currentPage = index
        updateLabels(for: index)
        visibleButton(index: index)
    }
    
    
}

protocol OnboardPageControlDelegate: AnyObject{
    func numberOfPage(numberOfPage: Int)
    func pageChangedTo(index: Int)
}
