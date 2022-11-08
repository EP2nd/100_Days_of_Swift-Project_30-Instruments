//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
    // MARK: - Delete:
//	var viewControllers = [UIViewController]() // create a cache of the detail view controllers for faster loading
	var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reactionist"
        
        tableView.rowHeight = 90
        tableView.separatorStyle = .none
        // MARK: - First part of second solution to wasted allocations:
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // MARK: - End of first part of second solution to wasted allocations.
        
        // load all the JPEGs into our array
        let fm = FileManager.default
        
        /// Challenge 1, step 1:
//        if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
//            for item in tempItems {
//                if item.range(of: "Large") != nil {
//                    items.append(item)
//                }
//            }
//        }
        if let path = Bundle.main.resourcePath {
            if let tempItems = try? fm.contentsOfDirectory(atPath: path) {
                for item in tempItems {
                    if item.range(of: "Large") != nil {
                        items.append(item)
                    }
                }
            }
        }
        /// End of challenge 1, step 1.
    }
    
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// MARK: - First solution for wasted allocations:
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
//        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell") // Note the force unwrapped optional at the end of the first line – we’re saying that cell might initially be empty, but it will definitely have a value by the time it’s used.
//
//        if cell == nil {
//            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
//        }
        // MARK: - End of first solution for wasted allocations.
        
        // MARK: - Second part of second solution to wasted allocations:
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // MARK: - End of second part of second solution to wasted allocations.

		// find the image for this cell, and load its thumbnail
		let currentImage = items[indexPath.row % items.count]
		let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
        /// Challenge 1, step 2:
//		let path = Bundle.main.path(forResource: imageRootName, ofType: nil)!
//		let original = UIImage(contentsOfFile: path)!
        if let path = Bundle.main.path(forResource: imageRootName, ofType: nil) {
            let original = UIImage(contentsOfFile: path)
            
            // MARK: - Option 2, part 1:
            let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90)) // <- Points, multiplied by 2 or 3, depending on the device.
            //let renderer = UIGraphicsImageRenderer(size: original.size)
            let renderer = UIGraphicsImageRenderer(size: renderRect.size)
            // MARK: - End of option 2, part 1.
            
            let rounded = renderer.image { ctx in
                // MARK: - Option 1:
                //            ctx.cgContext.setShadow(offset: .zero, blur: 200, color: UIColor.black.cgColor)
                //            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: original.size))
                //            ctx.cgContext.setShadow(offset: .zero, blur: .zero, color: nil)
                // MARK: - End of option 1.
                
                // MARK: - Option 2, part 2:
                //ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
                ctx.cgContext.addEllipse(in: renderRect)
                ctx.cgContext.clip()
                
                //original.draw(at: CGPoint.zero)
                original?.draw(in: renderRect)
                // MARK: - End of option 2, part 2:
            }
            
            cell.imageView?.image = rounded
            
            // give the images a nice shadow to make them look a bit more dramatic
            cell.imageView?.layer.shadowColor = UIColor.black.cgColor
            cell.imageView?.layer.shadowOpacity = 1
            cell.imageView?.layer.shadowRadius = 10
            cell.imageView?.layer.shadowOffset = CGSize.zero
            // MARK: - Option 3:
            cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath
        }
        /// End of challenge 1, step 2.
        
        // MARK: - End of option 3:

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

        // MARK: - Delete:
		// add to our view controller cache and show
//		viewControllers.append(vc)
        
        /// Challenge 1 bonus:
		navigationController?.pushViewController(vc, animated: true)
	}
}
