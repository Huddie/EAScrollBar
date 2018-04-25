//
//  NumbersViewController.swift
//  EAScrollBar-Example
//
//  Created by Ehud Adler on 1/31/18.
//  Copyright © 2018 Ehud Adler. All rights reserved.
//

import UIKit
import EAScrollBar


class NumbersViewController: UIViewController,
                             UITableViewDelegate,
                             UITableViewDataSource,
                             EAScrollDelegate {
  
  private var scrollIndicator = EAScrollIndicator()
  
  @IBOutlet var tableView: UITableView!
  
  override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {

    scrollIndicator = EAScrollIndicator(scrollView: self.tableView,
                                        points: [EAIndicatorPoint(title: "One", location: 400),
                                                 EAIndicatorPoint(title: "Two", location: 600),
                                                 EAIndicatorPoint(title: "Three", location: 900),
                                                 EAIndicatorPoint(title: "Four", location: 1000)])    
  }
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 100
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    cell.textLabel?.text = "\(indexPath.row)"
    return cell
  }

  func sectionPercent(percent: CGFloat) {
    /* Percent the section is complete */
  }
}

