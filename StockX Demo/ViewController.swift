//  Code Written by Adam J. Stern
//  June 6, 2018
//  Coding Demo for StockX
//  ViewController.swift
//  StockX Demo
//
//  Created by Adam Stern on 6/3/18.
//  Copyright © 2018 Adam Stern. All rights reserved.
//
//  Notable Features:
//  Keyboard return key and filter button both submit and dismiss the keyboard
//  Safari web view opens in app for easy access to links.
//
//  Know areas to improve:
//  The view table refresh is fairy janky, and while it works can be slow to update, especially when the subreddit filter has to apply to the first post in the list.
//  It works but there must be a way to load the new list in the background and update everything at once.



import UIKit
import SafariServices

//  Series of Structs to make up the structure of the Reddit JSON format
struct redditJson: Decodable {
    let kind: String?
    let data: redditJsonChildren?
}

struct redditJsonChildren: Decodable {
    let children: [redditPost]?
}

struct redditPost: Decodable {
    let data: redditPostDetails?
}

struct redditPostDetails: Decodable {
    let title: String?
    let subreddit: String?
    let url: String?
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    //  Arrays to store the data parsed from the JSON
    var subreddits: [String] = []
    var titles: [String] = []
    var URLs: [String] = []
    
    @IBOutlet weak var filterField: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //  Functionality for the filter button. Also dismisses the keyboard when pressed.
    @IBAction func filterButtonPress(_ sender: Any) {
        filterField.resignFirstResponder()
        initJson()
    }
    
    //  Similar functionality for the return key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        filterField.resignFirstResponder()
        filterPosts()
        return true
    }
    
    //  Calls the refresh on the table
    func filterPosts(){
        initJson()
    }
    
    func initJson() {
        self.subreddits.removeAll()
        self.titles.removeAll()
        self.URLs.removeAll()
        let subredditFilter = filterField.text
        var jsonURLString = "https://www.reddit.com"
        if (subredditFilter != ""){
            jsonURLString += "/r/" + subredditFilter!
        }
        jsonURLString += "/.json"
        guard let url = URL(string: jsonURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data else { return }
            
            do {
                let redditJsonVar = try JSONDecoder().decode(redditJson.self, from: data)
                for thing in (redditJsonVar.data?.children)! {
                    if (subredditFilter == ""){
                        self.subreddits.append((thing.data?.subreddit)!)
                        self.titles.append((thing.data?.title)!)
                        self.URLs.append((thing.data?.url)!)
                    }
                    else {
                        if (subredditFilter == thing.data?.subreddit){
                            self.subreddits.append((thing.data?.subreddit)!)
                            self.titles.append((thing.data?.title)!)
                            self.URLs.append((thing.data?.url)!)
                        }
                    }

                }
                
            } catch let jsonErr {
                
                
            }
            self.tableView.reloadData()
            }.resume()        // Do any additional setup after loading the view, typically from a nib.
    }
 
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        filterField.delegate = self
        super.viewDidLoad()
        initJson()
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return subreddits.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        
        cell.subreddit.text = "r/" + subreddits[indexPath.row]
        cell.title.text = titles[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLink = self.URLs[indexPath.row]
        let theURL = NSURL(string: selectedLink)
        let safariViewController = SFSafariViewController(url: theURL as! URL)
        safariViewController.delegate = self
        self.present(safariViewController, animated: true, completion: nil)
    }

}

extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


