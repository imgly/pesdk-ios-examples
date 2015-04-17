//
//  FilterSelectionController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

private let FilterCollectionViewCellReuseIdentifier = "FilterCollectionViewCell"
private let FilterCollectionViewCellSize = CGSize(width: 60, height: 90)
private let FilterActivationDuration = NSTimeInterval(0.15)

private var FilterPreviews = [FilterType : UIImage]()

public typealias FilterTypeSelectedBlock = (FilterType) -> (Void)
public typealias FilterTypeActiveBlock = () -> (FilterType)

@objc(IMGLYFilterSelectionController) public class FilterSelectionController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var selectedCellIndex: Int?
    public var selectedBlock: FilterTypeSelectedBlock?
    public var activeFilterType: FilterTypeActiveBlock?
    
    // MARK: - Initializers
    
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = FilterCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumInteritemSpacing = 7
        flowLayout.minimumLineSpacing = 7
        super.init(collectionViewLayout: flowLayout)
        
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView?.registerClass(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCellReuseIdentifier)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension FilterSelectionController: UICollectionViewDataSource {
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count(InstanceFactory.sharedInstance.availableFilterList)
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FilterCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        
        if let filterCell = cell as? FilterCollectionViewCell {
            let bundle = NSBundle(forClass: self.dynamicType)
            let filterType = InstanceFactory.sharedInstance.availableFilterList[indexPath.item]
            let filter = InstanceFactory.sharedInstance.effectFilterWithType(filterType)
            
            filterCell.textLabel.text = filter.displayName
            filterCell.imageView.layer.cornerRadius = 3
            filterCell.imageView.clipsToBounds = true
            filterCell.imageView.contentMode = .ScaleToFill
            filterCell.imageView.image = nil
            filterCell.hideTick()
            
            if let filterPreviewImage = FilterPreviews[filterType] {
                self.updateCell(filterCell, atIndexPath: indexPath, withFilterType: filter.filterType, forImage: filterPreviewImage)
                filterCell.activityIndicator.stopAnimating()
            } else {
                filterCell.activityIndicator.startAnimating()
                
                // Create filterPreviewImage
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                    let filterPreviewImage = PhotoProcessor.processWithUIImage(UIImage(named: "nonePreview", inBundle: bundle, compatibleWithTraitCollection:nil)!, filters: [filter])
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        FilterPreviews[filterType] = filterPreviewImage
                        if let filterCell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCollectionViewCell {
                            self.updateCell(filterCell, atIndexPath: indexPath, withFilterType: filter.filterType, forImage: filterPreviewImage)
                            filterCell.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Helpers
    
    private func updateCell(cell: FilterCollectionViewCell, atIndexPath indexPath: NSIndexPath, withFilterType filterType: FilterType, forImage image: UIImage?) {
        cell.imageView.image = image
        
        if let activeFilterType = activeFilterType?() where activeFilterType == filterType {
            cell.showTick()
            selectedCellIndex = indexPath.item
        }
    }
}

extension FilterSelectionController: UICollectionViewDelegate {
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)
        let extendedCellRect = CGRectInset(layoutAttributes.frame, -60, 0)
        collectionView.scrollRectToVisible(extendedCellRect, animated: true)
        
        if selectedCellIndex == indexPath.item {
            return
        }
        
        // get cell of previously selected filter if visible
        if let selectedCellIndex = self.selectedCellIndex, let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: selectedCellIndex, inSection: 0)) as? FilterCollectionViewCell {
            UIView.animateWithDuration(FilterActivationDuration, animations: { () -> Void in
                cell.hideTick()
            })
        }
        
        let filterType = InstanceFactory.sharedInstance.availableFilterList[indexPath.item]
        
        selectedBlock?(filterType)
        
        // get cell of newly selected filter
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCollectionViewCell {
            selectedCellIndex = indexPath.item
            
            UIView.animateWithDuration(FilterActivationDuration, animations: { () -> Void in
                cell.showTick()
            })
        }
    }
}
