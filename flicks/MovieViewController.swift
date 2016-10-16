//
//  MovieViewController.swift
//  flicks
//
//  Created by Hao on 10/11/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit

import AFNetworking

class MovieViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate {

    

    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewAsControl: UISegmentedControl!
    
    var movies: [NSDictionary]?;
    var endpoint: String!;
    var loaded:Bool = false;
    
    func refreshControlFactory()->UIRefreshControl{
        let refreshControl = UIRefreshControl();
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshControl.addTarget(self, action: #selector(self.refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        return refreshControl;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(refreshControlFactory())
        collectionView.addSubview(refreshControlFactory())
        
        tableView.dataSource = self;
        tableView.delegate = self;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetch();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func refreshControlAction(refreshControl: UIRefreshControl) {
        fetch(isForcing:true,refreshControl:refreshControl);
    }
    
    func fetch(isForcing:Bool = false,refreshControl:Any? = nil){
        
        if loaded && !isForcing{
            return;
        }
        if let ep = endpoint {
            ALLoadingView.manager.blurredBackground = true
            ALLoadingView.manager.showLoadingView(ofType: .messageWithIndicator, windowMode: .fullscreen)
            
            let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
            let url = URL(string: "https://api.themoviedb.org/3/movie/\(ep)?api_key=\(apiKey)")
            let request = URLRequest(
                url: url!,
                cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            let session = URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: nil,
                delegateQueue: OperationQueue.main
            )
            let task: URLSessionDataTask =
                session
                    .dataTask(
                        with: request,
                         completionHandler: { (dataOrNil, response, error) in
                            if let data = dataOrNil {
                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                    with: data, options:[]) as? NSDictionary {
                                    if let result = responseDictionary["results"] as? [NSDictionary] {
                                        self.movies = result;
                                        self.tableView.reloadData();
                                        self.collectionView.reloadData();
                                    }
                                    if let control =  refreshControl as? UIRefreshControl {
                                        control.endRefreshing();
                                    }
                                    self.errorLabel.isHidden = true;
                                }
                                else {
                                    self.errorLabel.isHidden = false;
                                }
                                
                                self.loaded = true;
                                
                            }
                            ALLoadingView.manager.hideLoadingView()
                        }
                    )
            task.resume();
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count;
        }
        return 0;
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell;
        
        let movie = movies![indexPath.row];
        
        
        if let path = movie["poster_path"]! as? String {
            cell.posterImageView.setImageWith(URL(string:"https://image.tmdb.org/t/p/w342" + path)!);
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let movies = movies {
            return movies.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"MovieCell", for: indexPath) as! MovieCell;
        
        let movie = movies![indexPath.row];
        
        cell.titleLabel?.text = movie["title"] as! String;
        cell.overviewLabel?.text = movie["overview"]! as! String;
        
        if let path = movie["poster_path"]! as? String {
            cell.posterView.setImageWith(URL(string:"https://image.tmdb.org/t/p/w342" + path)!);
        }
        
        
        return cell;
        
    }
    
    @IBAction func switchView(_ sender: AnyObject) {
    
        let isTable = viewAsControl.selectedSegmentIndex == 0 ? true : false;
        
        collectionView.isHidden = isTable;
        tableView.isHidden = !isTable;
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var index = 0;
        
        if sender is UITableViewCell {

            index = tableView.indexPath(for:sender as! UITableViewCell)!.row;
            
        }
        
        if sender is UICollectionViewCell {
            
            index = collectionView.indexPath(for: sender as! UICollectionViewCell)!.row;
            
        }
        
        let movie = movies![index];
        let detailViewController = segue.destination as! DetailViewController;
        
        detailViewController.movie = movie;
        
    }
    

}
