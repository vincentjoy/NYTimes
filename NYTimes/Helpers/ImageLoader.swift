//
//  ImageLoader.swift
//  NYTimes
//
//  Created by voonik on 30/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import UIKit

typealias ImageLoaderCompletionHandler = ((UIImage) -> ())?

class ImageLoader: Operation {
    
    var imageURLString: String
    var completionHandler: ImageLoaderCompletionHandler
    var image: UIImage?
    
    init(imageURLString: String) {
        self.imageURLString = imageURLString
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        if let imageURL = URL(string: imageURLString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL)
                if let imageData = data, let currentImage = UIImage(data: imageData) {
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self, !strongSelf.isCancelled else { return }
                        strongSelf.image = currentImage
                        strongSelf.completionHandler?(currentImage)
                    }
                }
            }
        }
    }
}
