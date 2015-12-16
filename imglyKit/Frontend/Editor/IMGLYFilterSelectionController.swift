//
//  IMGLYFilterSelectionController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

private let FilterCollectionViewCellReuseIdentifier = "FilterCollectionViewCell"
private let FilterCollectionViewCellSize = CGSize(width: 60, height: 90)
private let FilterActivationDuration = NSTimeInterval(0.15)

private var FilterPreviews = [IMGLYFilterType : UIImage]()

public typealias IMGLYFilterTypeSelectedBlock = (IMGLYFilterType, Float) -> (Void)
public typealias IMGLYFilterTypeActiveBlock = () -> (IMGLYFilterType?)

public class IMGLYFilterSelectionController: UICollectionViewController {
    
    // MARK: - Properties
    
    public var dataSource: IMGLYFiltersDataSourceProtocol = IMGLYFiltersDataSource()
    private var selectedCellIndex: Int?
    public var selectedBlock: IMGLYFilterTypeSelectedBlock?
    public var activeFilterType: IMGLYFilterTypeActiveBlock?
    
    // MARK: - Initializers
    
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = FilterCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumInteritemSpacing = 7
        flowLayout.minimumLineSpacing = 7
        super.init(collectionViewLayout: flowLayout)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.registerClass(IMGLYFilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCellReuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYFilterSelectionController {
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.filterCount
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FilterCollectionViewCellReuseIdentifier, forIndexPath: indexPath) 
        
        if let filterCell = cell as? IMGLYFilterCollectionViewCell {
            let filterType = dataSource.filterTypeAtIndex(indexPath.item)
            let filter = IMGLYInstanceFactory.effectFilterWithType(filterType)
            
            filterCell.textLabel.text = dataSource.titleForFilterAtIndex(indexPath.item)
            filterCell.imageView.layer.cornerRadius = 3
            filterCell.imageView.clipsToBounds = true
            filterCell.imageView.contentMode = .ScaleToFill
            filterCell.imageView.image = nil
            filterCell.tickImageView.image = self.dataSource.selectedImageForFilterAtIndex(indexPath.item)
            filterCell.hideTick()

            if let filterPreviewImage = FilterPreviews[filterType] {
                self.updateCell(filterCell, atIndexPath: indexPath, withFilterType: filterType, forImage: filterPreviewImage)
                filterCell.activityIndicator.stopAnimating()
            } else {
                filterCell.activityIndicator.startAnimating()
                
                // Create filterPreviewImage
                dispatch_async(PhotoProcessorQueue) {
                    let filterPreviewImage = IMGLYPhotoProcessor.processWithUIImage(self.dataSource.previewImageForFilterAtIndex(indexPath.item), filters: [filter])
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        FilterPreviews[filterType] = filterPreviewImage
                        if let filterCell = collectionView.cellForItemAtIndexPath(indexPath) as? IMGLYFilterCollectionViewCell {
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
    
    private func updateCell(cell: IMGLYFilterCollectionViewCell, atIndexPath indexPath: NSIndexPath, withFilterType filterType: IMGLYFilterType, forImage image: UIImage?) {
        cell.imageView.image = image
        
        if let activeFilterType = activeFilterType?() where activeFilterType == filterType {
            cell.showTick()
            selectedCellIndex = indexPath.item
        }
    }
}

extension IMGLYFilterSelectionController {
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath) {
            let extendedCellRect = CGRectInset(layoutAttributes.frame, -60, 0)
            collectionView.scrollRectToVisible(extendedCellRect, animated: true)
        }
        
        let filterType = self.dataSource.filterTypeAtIndex(indexPath.item)
        
        if selectedCellIndex == indexPath.item {
            selectedBlock?(filterType, self.dataSource.initialIntensityForFilterAtIndex(indexPath.item))
            return
        }
        
        // get cell of previously selected filter if visible
        if let selectedCellIndex = self.selectedCellIndex, let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: selectedCellIndex, inSection: 0)) as? IMGLYFilterCollectionViewCell {
            UIView.animateWithDuration(FilterActivationDuration, animations: { () -> Void in
                cell.hideTick()
            })
        }
        
        selectedBlock?(filterType, self.dataSource.initialIntensityForFilterAtIndex(indexPath.item))
        
        // get cell of newly selected filter
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? IMGLYFilterCollectionViewCell {
            selectedCellIndex = indexPath.item
            
            UIView.animateWithDuration(FilterActivationDuration, animations: { () -> Void in
                cell.showTick()
            })
        }
    }
}
