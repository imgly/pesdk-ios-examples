//
//  ZoomingImageView.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYZoomingImageViewDelegate) public protocol ZoomingImageViewDelegate: class {
    func zoomingImageViewDidZoom(zoomingImageView: ZoomingImageView)
}

@objc(IMGLYZoomingImageView) public class ZoomingImageView: UIScrollView {

    // MARK: - Properties

    public var image: UIImage? {
        get {
            return imageView.image
        }

        set {
            imageView.image = newValue
            imageView.sizeToFit()
            contentSize = imageView.frame.size
            initialZoomScaleWasSet = false
            setNeedsLayout()
        }
    }

    private let imageView = UIImageView()
    private var initialZoomScaleWasSet = false
    public lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTapped:")
        gestureRecognizer.numberOfTapsRequired = 2
        return gestureRecognizer
        }()

    public var visibleImageFrame: CGRect {
        var visibleImageFrame = bounds
        visibleImageFrame.intersectInPlace(imageView.frame)
        return visibleImageFrame
    }

    public weak var zoomDelegate: ZoomingImageViewDelegate?

    // MARK: - Initializers

    /**
    Initializes and returns a newly allocated view with the specified frame rectangle.

    - parameter frame: The frame rectangle for the view, measured in points.

    - returns: An initialized view object or `nil` if the object couldn't be created.
    */
    override init(frame: CGRect) {
        super.init(frame: CGRect())
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addSubview(imageView)
        addGestureRecognizer(doubleTapGestureRecognizer)

        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        maximumZoomScale = 2
        scrollsToTop = false
        decelerationRate = UIScrollViewDecelerationRateFast
        exclusiveTouch = true
        delegate = self
    }

    // MARK: - UIView

    public override func layoutSubviews() {
        super.layoutSubviews()

        if imageView.image != nil {
            if !initialZoomScaleWasSet {
                // Calculate ideal scale to make the image fit the frame of the image view
                let idealScale = min(frame.size.width / imageView.bounds.size.width, frame.size.height / imageView.bounds.size.height)

                // If the image is smaller than the bounds, the maximumZoomScale should match the
                // idealZoomScale
                if maximumZoomScale < idealScale {
                    maximumZoomScale = idealScale
                }

                // If the image is smaller than the bounds, the minimumZoomScale should always be 1
                // Otherwise the minimumZoomScale is the ideal scale
                minimumZoomScale = min(idealScale, 1)

                // Initially set the zoomScale to the ideal value
                zoomScale = idealScale

                initialZoomScaleWasSet = true
            }
        }
    }

    // MARK: - Actions

    @objc private func doubleTapped(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.locationInView(imageView)

        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            zoomToRect(CGRect(x: location.x, y: location.y, width: 1, height: 1), animated: true)
        }
    }
}

extension ZoomingImageView: UIScrollViewDelegate {
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((bounds.size.width - contentSize.width) * 0.5, 0)
        let offsetY = max((bounds.size.height - contentSize.height) * 0.5, 0)

        imageView.center = CGPoint(x: contentSize.width * 0.5 + offsetX, y: contentSize.height * 0.5 + offsetY)
        zoomDelegate?.zoomingImageViewDidZoom(self)
    }
}
