//
//  WelcomeVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/15/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController, UIScrollViewDelegate {
//IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize.width = scrollView.frame.width * CGFloat(pageControl.numberOfPages)

        // Do any additional setup after loading the view.
    }
    func scrollViewDidScroll(_ _scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPosition = scrollView.contentOffset.x
        let currentPage = currentPosition/pageWidth
        pageControl.currentPage = Int(currentPage)
    }
    
    @IBAction func onValueChangedPageControl(_ sender: Any) {
        let currentPage = pageControl.currentPage
        let pageWidth = scrollView.frame.size.width
        scrollView.contentOffset.x = pageWidth * CGFloat(currentPage)
    }
    
    // MARK: - IBAction
    @IBAction func onPressedAcceptTCS(_ sender: Any) {
        AppUserDefaults.isAcceptedTCS = true
        
        let signinNC = STORYBOARD.instantiateViewController(withIdentifier: "SigninNC")
        APPDELEGATE.window?.rootViewController = signinNC
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
