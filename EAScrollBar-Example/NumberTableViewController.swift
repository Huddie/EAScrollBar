//
//  NumberTableViewController.swift
//  EAScrollBar
//
//  Created by Ehud Adler on 1/30/18.
//  Copyright © 2018 Ehud Adler. All rights reserved.
//

import UIKit
import EAScrollBar

class NumberTableViewController: UITableViewController {
    private var scrollIndicator  = EAScrollIndicator()

  
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollIndicator = EAScrollIndicator(scrollView: tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 100
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

}
