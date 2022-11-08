//
//  ImageViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
	weak var owner: SelectionViewController!
    /// Challenge 1 bonus:
	var image: String?
    /// Challen 1 bonus:
	var animTimer: Timer?
    /// Challenge 1 bonus:
	var imageView: UIImageView?

	override func loadView() {
		super.loadView()
		
		view.backgroundColor = UIColor.black

		// create an image view that fills the screen
        /// Challenge 1 bonus:
        imageView = UIImageView()
        
        if let imageView = imageView {
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.alpha = 0

		view.addSubview(imageView)

		// make the image view fill the screen
		imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        // MARK: - Further looking for a reason of misbehaviour:
        /// The reason is that when you provide code for your timer to run, the timer holds a strong reference to it so it can definitely be called when the timer is up. We're using self inside our timer’s code, which means our view controller owns the timer strongly and the timer owns the view controller strongly, so we have a strong reference cycle.
		// schedule an animation that does something vaguely interesting
            animTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
                // do something exciting with our image
                imageView.transform = CGAffineTransform.identity
                
                UIView.animate(withDuration: 3) {
                    imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        /// Challenge 1 bonus:
        guard let imageView = imageView else { return }
        /// Challenge 1 bonus:
        if let image = image {
            title = image.replacingOccurrences(of: "-Large.jpg", with: "")
            // MARK: - Skipping using cache by creating our images using the UIImage(contentsOfFile: ) initializer instead:
            /// Challenge 1, step 3:
            //        let path = Bundle.main.path(forResource: image, ofType: nil)!
            if let path = Bundle.main.path(forResource: image, ofType: nil) {
                //let original = UIImage(named: image)!
                if let original = UIImage(contentsOfFile: path) {
                    // MARK: - End of solution.
                    
                    let renderer = UIGraphicsImageRenderer(size: original.size)
                    
                    let rounded = renderer.image { ctx in
                        ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
                        ctx.cgContext.closePath()
                        
                        original.draw(at: CGPoint.zero)
                    }
                    
                    imageView.image = rounded
                }
            }
        }
    }
    /// End of challenge 1, step 3.

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        /// Challenge 1 bonus:
        guard let imageView = imageView else { return }

		imageView.alpha = 0

		UIView.animate(withDuration: 3) {
			imageView.alpha = 1
		}
	}
    
    // MARK: - Further looking for a reason of misbehaviour:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// Challenge 1 bonus:
        guard let animTimer = animTimer else { return }
        
        animTimer.invalidate()
    }

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// Challenge 1 bonus:
        guard let image = image else { return }
        
		let defaults = UserDefaults.standard
        
		var currentVal = defaults.integer(forKey: image)
		currentVal += 1

		defaults.set(currentVal, forKey:image)

		// tell the parent view controller that it should refresh its table counters when we go back
		owner.dirty = true
	}
}
