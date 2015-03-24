//
//  IMGLYStickersDialogView.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public protocol IMGLYStickersDialogViewDelegate: class {
    func doneButtonPressed()
    func backButtonPressed()
}

public class IMGLYStickersDialogView: UIView {
    @IBOutlet public weak var contentView: UIView!
    @IBOutlet public weak var previewImageView: UIImageView!
    @IBOutlet public private(set) weak var collectionView: UICollectionView!
    public private(set) var stickersClipView: UIView!
    
    private let containerViewHelper = IMGLYInstanceFactory.sharedInstance.containerViewHelper()
    public weak var delegate: IMGLYStickersDialogViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    // MARK: - View connection
    public func setup() {
        containerViewHelper.loadXib("IMGLYStickersDialogView", view:self)
        containerViewHelper.addContentViewAndSetupConstraints(hostView: self, contentView: self.contentView)
        configureStickersClipView()
    }
    
    private func configureStickersClipView() {
        stickersClipView = UIView(frame: self.previewImageView.frame)
        stickersClipView.clipsToBounds = true
        self.addSubview(stickersClipView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // calculate frame of image within imageView
        let imageSize = scaledImageSize()
        let imageFrame = CGRect(x: CGRectGetMidX(self.previewImageView.frame) - imageSize.width / 2, y: CGRectGetMidY(self.previewImageView.frame) - imageSize.height / 2, width: imageSize.width, height: imageSize.height)
        
        stickersClipView.frame = imageFrame
    }
    
    @IBAction public func doneButtonPressed(sender: AnyObject) {
        self.delegate?.doneButtonPressed()
    }
    
    @IBAction public func backButtonPressed(sender: AnyObject) {
        self.delegate?.backButtonPressed()
    }
    
    // MARK: - Helpers
    
    private func scaledImageSize() -> CGSize {
        var widthRatio = self.previewImageView.bounds.size.width / self.previewImageView.image!.size.width
        var heightRatio = self.previewImageView.bounds.size.height / self.previewImageView.image!.size.height
        var scale = min(widthRatio, heightRatio)
        var size = CGSizeZero
        size.width = scale * self.previewImageView.image!.size.width
        size.height = scale * self.previewImageView.image!.size.height
        return size
    }
}
