//
//  OnboardPageViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/1/25.
//

import UIKit

class OnboardPageViewController: UIPageViewController {
    
    var contentPageViewControllerList = [UIViewController]()
    weak var onboardDelegate: OnboardPageControlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        let storyBoard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        contentPageViewControllerList = [
            storyBoard.instantiateViewController(withIdentifier: "First"),
            storyBoard.instantiateViewController(withIdentifier: "Second"),
            storyBoard.instantiateViewController(withIdentifier: "Third"),
            storyBoard.instantiateViewController(withIdentifier: "Fourth")
        ]
        
        onboardDelegate?.numberOfPage(numberOfPage: contentPageViewControllerList.count)
        setViewControllers([contentPageViewControllerList[0]], direction: .forward, animated: false, completion: nil)
    }
    
    func goToPage(index: Int){
        let currentViewController = viewControllers!.first!
        let currentViewControllerIndex = contentPageViewControllerList.firstIndex(of: currentViewController)!
        
        let direction: NavigationDirection = index > currentViewControllerIndex ? .forward : .reverse
        
        onboardDelegate?.numberOfPage(numberOfPage: contentPageViewControllerList.count)
        setViewControllers([contentPageViewControllerList[index]], direction: direction, animated: false, completion: nil)
    }
}

extension OnboardPageViewController: UIPageViewControllerDataSource {
    
    //이전 화면으로 스와이프 하면 이전 화면으로 어떤 뷰를 보여줄지 결정해 주는 데이터소스
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = contentPageViewControllerList.firstIndex(of: viewController)!
        
        if currentIndex == 0{
            return nil
        } else {
            return contentPageViewControllerList[currentIndex - 1]
        }
    }
    
    //다음화면으로 스와이프하면 다음화면으로 어떤 뷰를 보여줄지 결정해주는 데이터 소스
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = contentPageViewControllerList.firstIndex(of: viewController)!
        
        if currentIndex == contentPageViewControllerList.count - 1{
            return nil
        } else {
            return contentPageViewControllerList[currentIndex + 1]
        }
    }
}

extension OnboardPageViewController: UIPageViewControllerDelegate {
    
    //didFinishAnimating 페이지 이동 움직임이 끝났을 때 실행해 줄 것을 설정해 주는 것이다.
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentPageViewController = pageViewController.viewControllers?.first {
            let index = contentPageViewControllerList.firstIndex(of: currentPageViewController)!
            onboardDelegate?.pageChangedTo(index: index)
        }
        
    }
}
