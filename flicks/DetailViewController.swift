//
//  DetailViewController.swift
//  flicks
//
//  Created by Hao on 10/12/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit

import AFNetworking

class DetailViewController: UIViewController {
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie:NSDictionary!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        titleLabel?.text = movie["title"] as! String;
        overviewLabel?.text = movie["overview"]! as! String;
        overviewLabel.sizeToFit();
        
        if let path = movie["poster_path"]! as? String {
            posterView.setImageWith(URL(string:"https://image.tmdb.org/t/p/original" + path)!);
        }
        
        
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height + infoView.frame.size.height - 64;
        
        scrollView.contentSize = CGSize(width:contentWidth, height:contentHeight)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
