//
//  IMGLYClassfactory.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit

/**
  A singleton that is out to create objects. It is used within the SDK to 
  create filters, views, viewcontrollers and such.
*/
public class IMGLYInstanceFactory {
    public class var sharedInstance : IMGLYInstanceFactory {
        struct Static {
            static let instance : IMGLYInstanceFactory = IMGLYInstanceFactory()
        }
        return Static.instance
    }
    
    // MARK:- filter related
    public func photoProcessor() -> IMGLYPhotoProcessor {
        return IMGLYPhotoProcessor()
    }
    
    /**
    Creates a response filter with the specified type.
    
    :param: type The type of the filter that should be created.
    
    :returns: A CIFilter object that realizes the desired filter.
    */
    public func effectFilterWithType(type:IMGLYFilterType) -> CIFilter? {
        switch(type) {
        case IMGLYFilterType.None:
            return IMGLYNoneFilter()
        case IMGLYFilterType.K1:
            return IMGLYK1Filter()
        case IMGLYFilterType.K2:
            return IMGLYK2Filter()
        case IMGLYFilterType.K6:
            return IMGLYK6Filter()
        case IMGLYFilterType.KDynamic:
            return IMGLYKDynamicFilter()
        case IMGLYFilterType.Fridge:
            return IMGLYFridgeFilter()
        case IMGLYFilterType.Breeze:
            return IMGLYBreezeFilter()
        case IMGLYFilterType.Orchid:
            return IMGLYOrchidFilter()
        case IMGLYFilterType.Chest:
            return IMGLYChestFilter()
        case IMGLYFilterType.Front:
            return IMGLYFrontFilter()
        case IMGLYFilterType.Fixie:
            return IMGLYFixieFilter()
        case IMGLYFilterType.X400:
            return IMGLYX400Filter()
        case IMGLYFilterType.BW:
            return IMGLYBWFilter()
        case IMGLYFilterType.AD1920:
            return IMGLYAD1920Filter()
        case IMGLYFilterType.Lenin:
            return IMGLYLeninFilter()
        case IMGLYFilterType.Quozi:
            return IMGLYQuoziFilter()
        case IMGLYFilterType.Pola669:
            return IMGLYPola669Filter()
        case IMGLYFilterType.PolaSX:
            return IMGLYPolaSXFilter()
        case IMGLYFilterType.Food:
            return IMGLYFoodFilter()
        case IMGLYFilterType.Glam:
            return IMGLYGlamFilter()
        case IMGLYFilterType.Celsius:
            return IMGLYCelsiusFilter()
        case IMGLYFilterType.Texas:
            return IMGLYTexasFilter()
        case IMGLYFilterType.Lomo:
            return IMGLYLomoFilter()
        case IMGLYFilterType.Gobblin:
            return IMGLYGobblinFilter()
        case IMGLYFilterType.Sin:
            return IMGLYSinFilter()
        case IMGLYFilterType.Mellow:
            return IMGLYMellowFilter()
        case IMGLYFilterType.Sunny:
            return IMGLYSunnyFilter()
        case IMGLYFilterType.A15:
            return IMGLYA15Filter()
        case IMGLYFilterType.Soft:
            return IMGLYSoftFilter()
        case IMGLYFilterType.Blues:
            return IMGLYBluesFilter()
        case IMGLYFilterType.Elder:
            return IMGLYElderFilter()
        case IMGLYFilterType.Sunset:
            return IMGLYSunsetFilter()
        case IMGLYFilterType.Evening:
            return IMGLYEveningFilter()
        case IMGLYFilterType.Steel:
            return IMGLYSteelFilter()
        case IMGLYFilterType.Seventies:
            return IMGLYSeventiesFilter()
        case IMGLYFilterType.HighContrast:
            return IMGLYHighContrastFilter()
        case IMGLYFilterType.BlueShadows:
            return IMGLYBlueShadowsFilter()
        case IMGLYFilterType.Highcarb:
            return IMGLYHighcarbFilter()
        case IMGLYFilterType.Eighties:
            return IMGLYEightiesFilter()
        case IMGLYFilterType.Colorful:
            return IMGLYColorfulFilter()
        case IMGLYFilterType.Lomo100:
            return IMGLYLomo100Filter()
        case IMGLYFilterType.Pro400:
            return IMGLYPro400Filter()
        case IMGLYFilterType.Twilight:
            return IMGLYTwilightFilter()
        case IMGLYFilterType.CottonCandy:
            return IMGLYCottonCandyFilter()
        case IMGLYFilterType.Mono3200:
            return IMGLYMono3200Filter()
        case IMGLYFilterType.BlissfulBlue:
            return IMGLYBlissfulBlueFilter()
        case IMGLYFilterType.Pale:
            return IMGLYPaleFilter()
        case IMGLYFilterType.Settled:
            return IMGLYSettledFilter()
        case IMGLYFilterType.Cool:
            return IMGLYCoolFilter()
        case IMGLYFilterType.Litho:
            return IMGLYLithoFilter()
        case IMGLYFilterType.Prelude:
            return IMGLYPreludeFilter()
        case IMGLYFilterType.Nepal:
            return IMGLYNepalFilter()
        case IMGLYFilterType.Ancient:
            return IMGLYAncientFilter()
        case IMGLYFilterType.Pitched:
            return IMGLYPitchedFilter()
        case IMGLYFilterType.Lucid:
            return IMGLYLucidFilter()
        case IMGLYFilterType.Creamy:
            return IMGLYCreamyFilter()
        case IMGLYFilterType.Keen:
            return IMGLYKeenFilter()
        case IMGLYFilterType.Tender:
            return IMGLYTenderFilter()
        case IMGLYFilterType.Bleached:
            return IMGLYBleachedFilter()
        case IMGLYFilterType.BleachedBlue:
            return IMGLYBleachedBlueFilter()
        case IMGLYFilterType.Fall:
            return IMGLYFallFilter()
        case IMGLYFilterType.Winter:
            return IMGLYWinterFilter()
        case IMGLYFilterType.SepiaHigh:
            return IMGLYSepiaHighFilter()
        case IMGLYFilterType.Summer:
            return IMGLYSummerFilter()
        case IMGLYFilterType.Classic:
            return IMGLYClassicFilter()
        case IMGLYFilterType.NoGreen:
            return IMGLYNoGreenFilter()
        case IMGLYFilterType.Neat:
            return IMGLYNeatFilter()
        case IMGLYFilterType.Plate:
            return IMGLYPlateFilter()
        default:
            fatalError("No filter found for type \(type)")
        }
    }
    
    /**
    Creates a text filter.
    
    :returns: A text filter
    */
    public func textFilter() -> IMGLYTextFilter {
        return IMGLYTextFilter()
    }
    
    /**
    Creates a source filter for a still-image source.
    Use this as first filter within a chain of filters.
    
    :returns: A source filter
    */
    public func sourcePhotoFilter() -> IMGLYSourcePhotoFilter {
        return IMGLYSourcePhotoFilter()
    }
    
    /**
    Creates a crop filter.
    
    :returns: A crop filter
    */
    public func orientationCropFilter() -> IMGLYOrientationCropFilter {
        return IMGLYOrientationCropFilter()
    }
    
    /**
    Creates a tiltshift filter.
    
    :returns: A tiltshift filter.
    */
    public func tiltShiftFilter() -> IMGLYTiltshiftFilter {
        return IMGLYTiltshiftFilter()
    }
    
    /**
    Creates a color-adjustment filter.
    
    :returns: A color-adjustment filter.
    */
    public func colorAdjustmentFilter() -> IMGLYContrastBrightnessSaturationFilter {
        return IMGLYContrastBrightnessSaturationFilter()
    }
    
    /**
    Creates an enhancement filter.
    
    :returns: A enhancement filter.
    */
    public func enhancementFilter() -> IMGLYEnhancementFilter {
        return IMGLYEnhancementFilter()
    }
    
    /**
    Returns the list of filters, that should be available in the dialogs.
    Change this list to select the set of filters you want to present to the user.
    :returns: An array of filter types.
    */
    public func availableFilterList() -> [IMGLYFilterType] {
        return [IMGLYFilterType.None,
            IMGLYFilterType.K1,
            IMGLYFilterType.K2,
            IMGLYFilterType.K6,
            IMGLYFilterType.KDynamic,
            IMGLYFilterType.Fridge,
            IMGLYFilterType.Breeze,
            IMGLYFilterType.Orchid,
            IMGLYFilterType.Chest,
            IMGLYFilterType.Front,
            IMGLYFilterType.Fixie,
            IMGLYFilterType.X400,
            IMGLYFilterType.BW,
            IMGLYFilterType.AD1920,
            IMGLYFilterType.Lenin,
            IMGLYFilterType.Quozi,
            IMGLYFilterType.Pola669,
            IMGLYFilterType.PolaSX,
            IMGLYFilterType.Food,
            IMGLYFilterType.Glam,
            IMGLYFilterType.Celsius,
            IMGLYFilterType.Texas,
            IMGLYFilterType.Lomo,
            IMGLYFilterType.Gobblin,
            IMGLYFilterType.Sin,
            IMGLYFilterType.Mellow,
            IMGLYFilterType.Sunny,
            IMGLYFilterType.A15,
            IMGLYFilterType.Soft,
            IMGLYFilterType.Blues,
            IMGLYFilterType.Elder,
            IMGLYFilterType.Sunset,
            IMGLYFilterType.Evening,
            IMGLYFilterType.Steel,
            IMGLYFilterType.Seventies,
            IMGLYFilterType.HighContrast,
            IMGLYFilterType.BlueShadows,
            IMGLYFilterType.Highcarb,
            IMGLYFilterType.Eighties,
            IMGLYFilterType.Colorful,
            IMGLYFilterType.Lomo100,
            IMGLYFilterType.Pro400,
            IMGLYFilterType.Twilight,
            IMGLYFilterType.CottonCandy,
            IMGLYFilterType.Mono3200,
            IMGLYFilterType.BlissfulBlue,
            IMGLYFilterType.Pale,
            IMGLYFilterType.Settled,
            IMGLYFilterType.Cool,
            IMGLYFilterType.Litho,
            IMGLYFilterType.Prelude,
            IMGLYFilterType.Nepal,
            IMGLYFilterType.Ancient,
            IMGLYFilterType.Pitched,
            IMGLYFilterType.Lucid,
            IMGLYFilterType.Creamy,
            IMGLYFilterType.Keen,
            IMGLYFilterType.Tender,
            IMGLYFilterType.Bleached,
            IMGLYFilterType.BleachedBlue,
            IMGLYFilterType.Fall,
            IMGLYFilterType.Winter,
            IMGLYFilterType.SepiaHigh,
            IMGLYFilterType.Summer,
            IMGLYFilterType.Classic,
            IMGLYFilterType.NoGreen,
            IMGLYFilterType.Neat,
            IMGLYFilterType.Plate]
    }
    
    // MARK:- dialog viewcontroller
    
    /**
    Return the viewcontroller acording to the button-type.
    This is used by the main menu.
    
    :param: type The type of the button pressed.
    
    :returns: A viewcontroller acording to the button-type.
    */
    public func viewControllerForButtonType(type:IMGLYMainMenuButtonType) -> IMGLYSubEditorViewControllerProtocol? {
        switch (type) {
        case IMGLYMainMenuButtonType.Filter:
            return filterDialogViewController() as IMGLYSubEditorViewControllerProtocol
        case IMGLYMainMenuButtonType.Orientation:
            return orientationDialogViewController() as IMGLYSubEditorViewControllerProtocol
        case IMGLYMainMenuButtonType.Focus:
            return focusDialogViewController() as IMGLYSubEditorViewControllerProtocol
        case IMGLYMainMenuButtonType.Crop:
            return cropDialogViewController() as IMGLYSubEditorViewControllerProtocol
        case IMGLYMainMenuButtonType.Brightness:
            return brightnessDialogViewController() as IMGLYSubEditorViewControllerProtocol
        case IMGLYMainMenuButtonType.Contrast:
            return contrastDialogViewController() as IMGLYSubEditorViewControllerProtocol
        case IMGLYMainMenuButtonType.Saturation:
            return saturationDialogViewController() as IMGLYSubEditorViewControllerProtocol
        case IMGLYMainMenuButtonType.Noise:
            return IMGLYFilterDialogViewController() as IMGLYSubEditorViewControllerProtocol
        case IMGLYMainMenuButtonType.Text:
            return textDialogViewController() as IMGLYSubEditorViewControllerProtocol
        default:
            return nil
        }
    }
    
    public func filterDialogViewController() -> IMGLYFilterDialogViewController {
        return IMGLYFilterDialogViewController()
    }
    
    public func orientationDialogViewController() -> IMGLYOrientationDialogViewController {
        return IMGLYOrientationDialogViewController()
    }
    
    public func cropDialogViewController() -> IMGLYCropDialogViewController {
        return IMGLYCropDialogViewController()
    }
    
    public func brightnessDialogViewController() -> IMGLYBrightnessDialogViewController {
        return IMGLYBrightnessDialogViewController()
    }
    
    public func contrastDialogViewController() -> IMGLYContrastDialogViewController {
        return IMGLYContrastDialogViewController()
    }
    
    public func saturationDialogViewController() -> IMGLYSaturationDialogViewController {
        return IMGLYSaturationDialogViewController()
    }
    
    public func textDialogViewController() -> IMGLYTextDialogViewController {
        return IMGLYTextDialogViewController()
    }
    
    public func focusDialogViewController() -> IMGLYFocusDialogViewController {
        return IMGLYFocusDialogViewController()
    }
    
    // Dialog-views
    /**
    Return the view acording to the button-type.
    This is used by the main menu.
    
    :param: type The type of the button pressed.
    
    :returns: A view acording to the button-type.
    */

    public func viewForButtonType(type:IMGLYMainMenuButtonType) -> UIView? {
        switch (type) {
        case IMGLYMainMenuButtonType.Filter:
            return filterDialogView() as UIView
        case IMGLYMainMenuButtonType.Orientation:
            return orientationDialogView() as UIView
        case IMGLYMainMenuButtonType.Focus:
            return focusDialogView() as UIView
        case IMGLYMainMenuButtonType.Crop:
            return cropDialogView() as UIView
        case IMGLYMainMenuButtonType.Brightness:
            return oneSliderDialogView() as UIView
        case IMGLYMainMenuButtonType.Contrast:
            return oneSliderDialogView() as UIView
        case IMGLYMainMenuButtonType.Saturation:
            return oneSliderDialogView() as UIView
        case IMGLYMainMenuButtonType.Noise:
            return filterDialogView() as UIView
        case IMGLYMainMenuButtonType.Text:
            return textDialogView() as UIView
        default:
            return nil
        }
    }
    
    public func filterDialogView() -> IMGLYFilterDialogView {
        var dialog = IMGLYFilterDialogView(frame: CGRectZero)
        return dialog
    }
    
    public func focusDialogView() -> IMGLYFocusDialogView {
        var dialog = IMGLYFocusDialogView(frame: CGRectZero)
        return dialog
    }
    
    public func oneSliderDialogView() -> IMGLYOneSliderDialogView {
        var dialog = IMGLYOneSliderDialogView(frame: CGRectZero)
        return dialog
    }
    
    public func cropDialogView() -> IMGLYCropDialogView {
        var dialog = IMGLYCropDialogView(frame: CGRectZero)
        return dialog
    }
    
    public func textDialogView() -> IMGLYTextDialogView {
        var dialog = IMGLYTextDialogView(frame: CGRectZero)
        return dialog
    }

    public func orientationDialogView() -> IMGLYOrientationDialogView {
        var dialog = IMGLYOrientationDialogView(frame:CGRectZero)
        return dialog
    }
    
    // MARK:- gradiant-views
    public func circleGradientView() -> IMGLYCircleGradientView {
        return IMGLYCircleGradientView(frame: CGRectZero)
    }

    public func boxGradientView() -> IMGLYBoxGradientView {
        return IMGLYBoxGradientView(frame: CGRectZero)
    }
    
    // MARK:- font related 
    
    /**
    Returns a list that determins what fonts will be available within
    the text-dialog.
    
    :returns: An array of fontnames.
    */
    public func availableFontsList() -> [String] {
        return ["AmericanTypewriter",
            "Avenir-Heavy",
            "ChalkboardSE-Regular",
            "ArialMT",
            "BanglaSangamMN",
            "Liberator",
            "Muncie",
            "Abraham Lincoln",
            "Airship 27",
            "Arvil",
            "Bender",
            "Blanch",
            "Cubano",
            "Franchise",
            "Geared Slab",
            "Governor",
            "Haymaker",
            "Homestead",
            "Maven Pro Light",
            "Mensch",
            "Sullivan",
            "Tommaso",
            "Valencia",
            "Vevey"]
    }
    
    public func fontImporter() -> IMGLYFontImporter {
        return IMGLYFontImporter()
    }
    
    // MARK:- helpers    
    public func containerViewHelper() -> IMGLYContainerViewHelper {
        return IMGLYContainerViewHelper()
    }
    
    public func cropRectComponent() -> IMGLYCropRectComponent {
        return IMGLYCropRectComponent()
    }
    

}