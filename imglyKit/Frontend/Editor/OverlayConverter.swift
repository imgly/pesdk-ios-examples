//
//  OverlayConverter.swift
//  imglyKit
//
//  This class is out to convert sticker and texts filters to UI elements,
//  and vice versa.
//  Created by Carsten Przyluczky on 17/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYOverlayConverter) public class OverlayConverter: NSObject {

    private var fixedFilterStack: FixedFilterStack = FixedFilterStack()

    init(fixedFilterStack: FixedFilterStack) {
        super.init()
        self.fixedFilterStack = fixedFilterStack
    }

    // MARK:- stickers -> UI elements
    /*
    * in this method we do some calculations to re calculate the
    * sticker position in relation to the crop region.
    * Therefore we calculte the position and size within the non-cropped image
    * and apply the translation and scaling that comes with cropping in relation
    * to the full image.
    * When we are done we must revoke that extra transformation.
    */
    public func addStickerImagesFromStickerFilters(stickerFilters: [Filter], containerView: UIView) {
        for element in stickerFilters {
            guard let stickerFilter = element as? StickerFilter else {
                return
            }
            let imageView = UIImageView(image: stickerFilter.sticker)
            imageView.userInteractionEnabled = true
            let cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
            var completeSize = containerView.bounds.size
            completeSize.width *= 1.0 / cropRect.width
            completeSize.height *= 1.0 / cropRect.height
            let size = stickerFilter.absolutStickerSizeForImageSize(completeSize)
            imageView.frame.size = size
            print(stickerFilter.center)
            var center = CGPoint(x: stickerFilter.center.x * completeSize.width,
                y: stickerFilter.center.y * completeSize.height)
            center.x -= (cropRect.origin.x * completeSize.width)
            center.y -= (cropRect.origin.y * completeSize.height)
            imageView.center = center
            imageView.transform = stickerFilter.transform
            containerView.addSubview(imageView)
        }
    }

    public func addTextsFromTextFilters(textFilters: [Filter], containerView: UIView, previewSize: CGSize) {
        for element in textFilters {
            guard let textFilter = element as? TextFilter else {
                return
            }
            let label = UILabel()
            label.userInteractionEnabled = true
            let cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
            var completeSize = previewSize
            completeSize.width *= 1.0 / cropRect.width
            completeSize.height *= 1.0 / cropRect.height
            label.font = UIFont(name: textFilter.fontName, size: textFilter.initialFontSize * previewSize.height)
            label.text = textFilter.text
            label.sizeToFit()
            label.transform = textFilter.transform

            var center = CGPoint(x: textFilter.center.x * completeSize.width,
                y: textFilter.center.y * completeSize.height)
            center.x -= cropRect.origin.x
            center.y -= cropRect.origin.y
            center.x /= cropRect.width
            center.y /= cropRect.height

            label.center = center
            label.clipsToBounds = false
            label.textColor = textFilter.color
            label.backgroundColor = textFilter.backgroundColor
            containerView.addSubview(label)
        }
    }

    // MARK:- UI elements -> stickers

    public func addStickersFiltersFromUIElements(containerView: UIView) -> Bool {
        var addedStickers = false

        for view in containerView.subviews {
            if let view = view as? UIImageView {
                if let image = view.image {
                    let stickerFilter = InstanceFactory.stickerFilter()
                    stickerFilter.sticker = image
                    stickerFilter.cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
                    let cropRect = stickerFilter.cropRect
                    let completeSize = containerView.bounds.size
                    var center = CGPoint(x: view.center.x / completeSize.width,
                        y: view.center.y / completeSize.height)
                    center.x *= cropRect.width
                    center.y *= cropRect.height
                    center.x += cropRect.origin.x
                    center.y += cropRect.origin.y
                    var size = initialSizeForStickerImage(image, containerView: containerView)
                    size.width = size.width / completeSize.width
                    size.height = size.height / completeSize.height
                    stickerFilter.center = center
                    stickerFilter.scale = size.width
                    stickerFilter.transform = view.transform
                    fixedFilterStack.stickerFilters.append(stickerFilter)
                    addedStickers = true
                }
            }
        }
        return addedStickers
    }

    public func addTextFiltersFromUIElements(containerView: UIView, previewSize: CGSize, previewImage: UIImage) {
        let completeSize = containerView.bounds.size
        let cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
        for view in containerView.subviews {
            if let label = view as? UILabel {
                print(label.center, completeSize)
                print(label.font)
                print(label.frame.size)
                let textFilter = InstanceFactory.textFilter()
                // swiftlint:disable force_cast
                textFilter.inputImage = previewImage.CIImage // self.previewImageView.image!.CIImage
                // swiftlint:enable force_cast
                textFilter.cropRect = cropRect
                var center = CGPoint(x: label.center.x / completeSize.width,
                    y: label.center.y / completeSize.height)
                center.x *= cropRect.width
                center.y *= cropRect.height
                center.x += cropRect.origin.x
                center.y += cropRect.origin.y
                textFilter.fontName = label.font.fontName
                textFilter.text = label.text ?? ""
                textFilter.initialFontSize = label.font.pointSize / previewSize.height //previewImageView.visibleImageFrame.size.height
                textFilter.color = label.textColor
                textFilter.backgroundColor = label.backgroundColor!
                textFilter.transform = label.transform
                textFilter.center = center
                fixedFilterStack.textFilters.append(textFilter)
            }
        }
    }

    // MARK: - Helpers

    public func initialSizeForStickerImage(image: UIImage, containerView: UIView) -> CGSize {
        let initialMaxStickerSize = containerView.bounds.width * 0.3
        let widthRatio = initialMaxStickerSize / image.size.width
        let heightRatio = initialMaxStickerSize / image.size.height
        let scale = min(widthRatio, heightRatio)
        return CGSize(width: image.size.width * scale, height: image.size.height * scale)
    }
}
