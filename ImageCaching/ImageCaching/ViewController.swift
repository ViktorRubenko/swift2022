//
//  ViewController.swift
//  ImageCaching
//
//  Created by Victor Rubenko on 09.03.2022.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var imageManager = {ImageManager()}()
    private var tableView: UITableView!
    private var imageURLS = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("THERE")
        setupViews()
        let group = imageManager.getImageURLS()
        group.notify(queue: .main) {
            print("notify")
            self.imageURLS = self.imageManager.imageURLS
            self.tableView.reloadData()
        }
    }
    
    func setupViews() {
        tableView = UITableView()
        tableView.frame = view.bounds
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imageURLS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.imageView?.clipsToBounds = true
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = String(indexPath.row)
        let token = imageManager.loadImage(imageURLS[indexPath.row]) { result in
            do {
                let image = try result.get()
                DispatchQueue.main.async {
                    contentConfig.image = image
                    cell.contentConfiguration = contentConfig
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        cell.contentConfiguration = contentConfig
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
}
