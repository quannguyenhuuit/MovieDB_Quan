//
//  MoviesTableViewController.swift
//  AppMovieDB
//
//  Created by Cntt18 on 5/19/17.
//  Copyright © 2017 Cntt18. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController {
    
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovieList()
    }
    
    func loadMovieList() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/550?api_key=b766a5163ab434a302a85bdb77bb41dd")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask: URLSessionDataTask? = session.dataTask(with: url! as URL) {
            data, response, error in
            
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if let httpURLRes = response as? HTTPURLResponse {
                
                if httpURLRes.statusCode == 200 {
                    do {
                        if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
                            
                            if let array: AnyObject = response["results"] {
                                
                                for movieDictonary in array as! [AnyObject] {
                                    if let movieDictonary = movieDictonary as? [String: AnyObject], let title = movieDictonary["title"] as? String {
                                        
                                        let id_movie = movieDictonary["id"] as? Int
                                        let poster = movieDictonary["poster_path"] as? String
                                        let overview = movieDictonary["overview"] as? String
                                        let releaseDate = movieDictonary["release_date"] as? String
                                        
                                        self.movies.append(Movie(id: id_movie, title: title, poster: poster, overview: overview, releaseDate: releaseDate, image: #imageLiteral(resourceName: "No_picture_available")))
                                    } else {
                                        
                                        print("Not a dictionary")
                                        
                                    }
                                }
                            } else {
                                
                                print("Results key not found in dictionary")
                                
                            }
                        } else {
                            
                            print("JSON Error")
                            
                        }
                    } catch let error as NSError {
                        print("Error parsing results: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.setContentOffset(CGPoint.zero, animated: false)
                    }
                    
                }
            }
        }
        
        dataTask?.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie: Movie
        movie = movies[indexPath.row]
        cell.imageView?.image = #imageLiteral(resourceName: "No_picture_available")
        OperationQueue().addOperation { () -> Void in
            if let img = Downloader.downloadImageWithURL("https://image.tmdb.org/t/p/w320\(movie.poster!)") {
                OperationQueue.main.addOperation({
                    self.movies[indexPath.row].image = img
                    cell.imageView?.image = img
                })
            }
        }
        
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = movie.overview
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != nil {
            
            let movieDetailVC = segue.destination as! MovieDetailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                movieDetailVC.id = movies[indexPath.row].id!
                movieDetailVC.image = movies[indexPath.row].image!
            }
        }
    }
}

class Downloader {
    class func downloadImageWithURL(_ url:String) -> UIImage! {
        let data = try? Data(contentsOf: URL(string: url)!)
        return UIImage(data: data!)
    }
}
