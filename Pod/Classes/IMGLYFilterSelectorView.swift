//
//  IMGLYFilterSelectorView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 04/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public protocol IMGFilterSelectorViewDelegate {
    func didSelectFilter(filter:IMGLYFilterType)
}

public class IMGLYFilterSelectorView: UIView {
    public let kIMGLYPreviewImageOffsetY = CGFloat(20.0)
    public let kIMGLYPreviewImageDistance = CGFloat(10.0)
    public let kIMGLYPreviewImageTextHeight = CGFloat(18.0)
    public let kIMGLYPreviewButtonSize = CGFloat(56.5)
    public let kActivationDuration:Double = 0.15
    
    private var lastClickedFilterButton_:UIButton? = nil
    private var contextQueue_:dispatch_queue_t? = nil
    private var availableFilterList_:[IMGLYFilterType] = []
    private var scrollView_:UIScrollView? = nil
    private var tickImageView_:UIImageView? = nil
    
    public var delegate:IMGFilterSelectorViewDelegate?
    
    public var activeFilterType_:IMGLYFilterType = IMGLYFilterType.None
    public var activeFilterType:IMGLYFilterType {
        get {
            return activeFilterType_
        }
        set (filterType) {
            activeFilterType_ = filterType
            setButtonAsActiveForFilterType(filterType)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        //      commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //       commonInit()
    }
    
    public func commonInit() {
        availableFilterList_ = IMGLYInstanceFactory.sharedInstance.availableFilterList()
        contextQueue_ = dispatch_queue_create("ly.img.filterPreviewQueue", DISPATCH_QUEUE_SERIAL)
        self.addScrollView()
        self.buildFilterPreviewButtons()
        self.rearrangeViews()
        self.recalculateScrollViewContentSize()
        self.addTickImageView()
        self.setFirstFilterAsActive()
    }
    
    private func addScrollView() {
        var scrollViewFrame = CGRectMake(0, 0, 768, self.frame.height)
        scrollView_ = UIScrollView(frame: scrollViewFrame)
        scrollView_!.showsHorizontalScrollIndicator = false
        scrollView_!.showsVerticalScrollIndicator = false
        self.addSubview(scrollView_!)
        var constraintHelper = IMGLYInstanceFactory.sharedInstance.containerViewHelper()
        constraintHelper.addContentViewAndSetupConstraints(hostView: self, contentView: scrollView_!)
    }
    
    private func buildFilterPreviewButtons() {
        var index = 0
        for filter in availableFilterList_ {
            addButtonForFilter(filter, index:index)
            index++
        }
    }
    
    private func addButtonForFilter(type:IMGLYFilterType, index:Int) {
        var button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.addTarget(self, action:"filterButtonTouchedUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.tag = type.rawValue
        self.scrollView_!.addSubview(button)
        
        var label = UILabel()
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor(white: 0.5, alpha: 1.0)
        label.font = UIFont(name: "Helvetica Neue", size:11.0)
        self.scrollView_!.addSubview(label)
        
        var activity = UIActivityIndicatorView()
        activity.startAnimating()
        self.scrollView_!.addSubview(activity)
        
        var image = UIImage(named: "nonePreview", inBundle: NSBundle(forClass: IMGLYFilterSelectorView.self), compatibleWithTraitCollection:nil)
        dispatch_async(contextQueue_!, {
            autoreleasepool {
                var actualFilter:CIFilter? = IMGLYInstanceFactory.sharedInstance.effectFilterWithType(type)
                var filtredImage:UIImage? = IMGLYPhotoProcessor.processWithUIImage(image!, filters: [actualFilter!])
                var text = actualFilter!.displayName
                actualFilter = nil
                dispatch_async(dispatch_get_main_queue(), {
                    activity.stopAnimating()
                    activity.removeFromSuperview()
                    label.text = text
                    button.setImage(filtredImage!, forState: UIControlState.Normal)
                    filtredImage = nil
                })
            }
        })
    }
    
    private func rearrangeViews() {
        var xOffset:CGFloat = 5
        for var index = 0; index < availableFilterList_.count; index++ {
            var button = scrollView_!.subviews[index * 3] as! UIView
            button.frame = CGRectMake(xOffset, kIMGLYPreviewImageOffsetY, kIMGLYPreviewButtonSize, kIMGLYPreviewButtonSize)
            
            let filter = availableFilterList_[index]
            var label = scrollView_!.subviews[index * 3 + 1] as! UILabel
            label.frame = CGRectMake(xOffset, kIMGLYPreviewButtonSize + kIMGLYPreviewImageOffsetY, kIMGLYPreviewButtonSize, kIMGLYPreviewImageTextHeight);
            
            var activity = scrollView_!.subviews[index * 3 + 2] as! UIView
            activity.frame = button.frame
            xOffset += kIMGLYPreviewImageDistance + kIMGLYPreviewButtonSize
        }
    }
    
    private func recalculateScrollViewContentSize() {
        let contentWidth = CGFloat(availableFilterList_.count) * (kIMGLYPreviewButtonSize + kIMGLYPreviewImageDistance)
        scrollView_!.contentSize = CGSizeMake(contentWidth, 1.0)
    }
    
    private func addTickImageView() {
        tickImageView_ = UIImageView()
        tickImageView_!.contentMode = UIViewContentMode.Center
        tickImageView_!.frame = CGRectMake(0, 0, kIMGLYPreviewButtonSize, kIMGLYPreviewButtonSize)
        tickImageView_!.image = UIImage(named: "icon_tick", inBundle: NSBundle(forClass: IMGLYFilterSelectorView.self), compatibleWithTraitCollection:nil)
        tickImageView_!.center = scrollView_!.subviews[0].center
        self.scrollView_!.addSubview(tickImageView_!)
    }
    
    private func setFirstFilterAsActive() {
        var button = scrollView_!.subviews[0] as! UIButton
        filterButtonTouchedUpInside(button)
    }
    
    public func filterButtonTouchedUpInside(button:UIButton) {
        var index = button.tag
        var filterType = IMGLYFilterType(rawValue: index)!
        if filterType == activeFilterType_ {
            return
        }
        if let delegate = self.delegate {
            delegate.didSelectFilter(filterType)
        }
        activeFilterType_ = filterType
        autoscrollLeftIfNeededFromXPosition(button.frame.origin.x)
        autoscrollRightIfNeededFromXPosition(button.frame.origin.x + button.frame.size.width)
        if button != lastClickedFilterButton_ {
            deactivateLastClickedButton()
            activateButton(button)
            lastClickedFilterButton_ = button
        }
    }
    
    private func autoscrollLeftIfNeededFromXPosition(xPosition:CGFloat) {
        var bottonPositionOnScreenX = xPosition - scrollView_!.contentOffset.x
        if bottonPositionOnScreenX < kIMGLYPreviewButtonSize {
            var cellWidth = kIMGLYPreviewButtonSize + kIMGLYPreviewImageDistance
            var cellNumber = scrollView_!.contentOffset.x / cellWidth
            cellNumber = CGFloat(floorf(Float(cellNumber)))
            if bottonPositionOnScreenX <= (kIMGLYPreviewImageDistance / 2.0) {
                cellNumber--
            }
            var newOffsetX = cellNumber * cellWidth
            newOffsetX = max(0.0, newOffsetX)
            scrollView_!.setContentOffset(CGPointMake(newOffsetX, 0.0), animated:true)
        }
    }
    
    private func autoscrollRightIfNeededFromXPosition(xPosition:CGFloat) {
        var bottonPositionOnScreenX = xPosition - scrollView_!.contentOffset.x
        if bottonPositionOnScreenX > (scrollView_!.frame.size.width - kIMGLYPreviewButtonSize) {
            var cellWidth = kIMGLYPreviewButtonSize + kIMGLYPreviewImageDistance
            var cellNumber = scrollView_!.contentOffset.x / cellWidth
            cellNumber = CGFloat(ceilf(Float(cellNumber))) + 1
            var newOffsetX = cellNumber * cellWidth
            newOffsetX = min(scrollView_!.contentSize.width -  scrollView_!.frame.size.width, newOffsetX)
            scrollView_!.setContentOffset(CGPointMake(newOffsetX, 0.0), animated:true)
        }
    }
    
    private func deactivateLastClickedButton() {
        if lastClickedFilterButton_ != nil {
            UIView.animateWithDuration(kActivationDuration, animations:{
                self.lastClickedFilterButton_!.alpha = 1.0
            })
        }
    }
    
    private func activateButton(button:UIButton!) {
        tickImageView_!.center = button.center
        UIView.animateWithDuration(kActivationDuration, animations:{
            button.alpha = 0.4;
        })
    }
    
    private func setButtonAsActiveForFilterType(filterType:IMGLYFilterType) {
        for view in scrollView_!.subviews {
            if let button = view as? UIButton {
                if button.tag == filterType.rawValue {
                    filterButtonTouchedUpInside(button)
                }
            }
        }
    }
}
