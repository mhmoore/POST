//
//  PostListViewController.swift
//  Post
//
//  Created by Michael Moore on 8/12/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var postController = PostController()
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var postTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.delegate = self
        postTableView.dataSource = self
        
        postController.fetchPosts {
            DispatchQueue.main.async {
                self.reloadTableView()
            }
        }
        
        postTableView.estimatedRowHeight = 45
        postTableView.rowHeight = UITableView.automaticDimension
        
        postTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
    }
    
    func reloadTableView() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postTableView.reloadData()
    }
    
    @objc func refreshControlPulled() {
        postController.fetchPosts {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) \(post.timestamp)"
        
        return cell
    }
    
    func presentErrorAlert() {
        let alert = UIAlertController(title: "Missing some stuff", message: "Please don't forget to include a username AND a message. Thanks!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            self.presentNewPostAlert()
        }))
        self.present(alert, animated: true, completion: nil)
        return
    }

    func presentNewPostAlert() {
        let alert = UIAlertController(title: "Add a new Post!", message: "Care to share?", preferredStyle: .alert)
        alert.addTextField { (textField) in
        }
        alert.addTextField { (textField) in
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            guard let username = alert.textFields?[0].text,
                let message = alert.textFields?[1].text else { return }
            if !username.isEmpty && !message.isEmpty {
                self.postController.addNewPostWith(username: username, text: message, completion: {
                    DispatchQueue.main.async {
                        self.reloadTableView()
                    }
                })
            } else {
                self.presentErrorAlert()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewPostAlert()
    }
}

extension PostListViewController {
// checks for when the user has scrolled to the end of the table view and calls the updated fetchPosts with correct parameters
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let postsCount = (postController.posts.count - 1)

        if row >= postsCount {
            postController.fetchPosts(reset: false) {
                self.reloadTableView()
            }
        }
        return
    }
}
