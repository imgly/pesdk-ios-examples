//
//  IMGLYInstanceFactory.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**
  A singleton that is out to create objects. It is used within the SDK to
  create filters, views, viewcontrollers and such.
*/
public class IMGLYInstanceFactory {
    /**
    Creates a response filter with the specified type.

    - parameter type: The type of the filter that should be created.

    - returns: A CIFilter object that realizes the desired filter.
    */
    public class func effectFilterWithType(type: IMGLYFilterType) -> IMGLYResponseFilter {
        switch type {
        case .None:
            return IMGLYNoneFilter()
        case .K1:
            return IMGLYK1Filter()
        case .K2:
            return IMGLYK2Filter()
        case .K6:
            return IMGLYK6Filter()
        case .KDynamic:
            return IMGLYKDynamicFilter()
        case .Fridge:
            return IMGLYFridgeFilter()
        case .Breeze:
            return IMGLYBreezeFilter()
        case .Orchid:
            return IMGLYOrchidFilter()
        case .Chest:
            return IMGLYChestFilter()
        case .Front:
            return IMGLYFrontFilter()
        case .Fixie:
            return IMGLYFixieFilter()
        case .X400:
            return IMGLYX400Filter()
        case .BW:
            return IMGLYBWFilter()
        case .AD1920:
            return IMGLYAD1920Filter()
        case .Lenin:
            return IMGLYLeninFilter()
        case .Quozi:
            return IMGLYQuoziFilter()
        case .Pola669:
            return IMGLYPola669Filter()
        case .PolaSX:
            return IMGLYPolaSXFilter()
        case .Food:
            return IMGLYFoodFilter()
        case .Glam:
            return IMGLYGlamFilter()
        case .Celsius:
            return IMGLYCelsiusFilter()
        case .Texas:
            return IMGLYTexasFilter()
        case .Lomo:
            return IMGLYLomoFilter()
        case .Goblin:
            return IMGLYGoblinFilter()
        case .Sin:
            return IMGLYSinFilter()
        case .Mellow:
            return IMGLYMellowFilter()
        case .Soft:
            return IMGLYSoftFilter()
        case .Blues:
            return IMGLYBluesFilter()
        case .Elder:
            return IMGLYElderFilter()
        case .Sunset:
            return IMGLYSunsetFilter()
        case .Evening:
            return IMGLYEveningFilter()
        case .Steel:
            return IMGLYSteelFilter()
        case .Seventies:
            return IMGLYSeventiesFilter()
        case .HighContrast:
            return IMGLYHighContrastFilter()
        case .BlueShadows:
            return IMGLYBlueShadowsFilter()
        case .Highcarb:
            return IMGLYHighcarbFilter()
        case .Eighties:
            return IMGLYEightiesFilter()
        case .Colorful:
            return IMGLYColorfulFilter()
        case .Lomo100:
            return IMGLYLomo100Filter()
        case .Pro400:
            return IMGLYPro400Filter()
        case .Twilight:
            return IMGLYTwilightFilter()
        case .CottonCandy:
            return IMGLYCottonCandyFilter()
        case .Pale:
            return IMGLYPaleFilter()
        case .Settled:
            return IMGLYSettledFilter()
        case .Cool:
            return IMGLYCoolFilter()
        case .Litho:
            return IMGLYLithoFilter()
        case .Ancient:
            return IMGLYAncientFilter()
        case .Pitched:
            return IMGLYPitchedFilter()
        case .Lucid:
            return IMGLYLucidFilter()
        case .Creamy:
            return IMGLYCreamyFilter()
        case .Keen:
            return IMGLYKeenFilter()
        case .Tender:
            return IMGLYTenderFilter()
        case .Bleached:
            return IMGLYBleachedFilter()
        case .BleachedBlue:
            return IMGLYBleachedBlueFilter()
        case .Fall:
            return IMGLYFallFilter()
        case .Winter:
            return IMGLYWinterFilter()
        case .SepiaHigh:
            return IMGLYSepiaHighFilter()
        case .Summer:
            return IMGLYSummerFilter()
        case .Classic:
            return IMGLYClassicFilter()
        case .NoGreen:
            return IMGLYNoGreenFilter()
        case .Neat:
            return IMGLYNeatFilter()
        case .Plate:
            return IMGLYPlateFilter()
        }
    }

    /**
    Creates a text filter.

    - returns: A text filter
    */
    public class func textFilter() -> IMGLYTextFilter {
        return IMGLYTextFilter()
    }

    /**
    Creates a sticker filter.

    - returns: A sticker filter
    */
    public class func stickerFilter() -> IMGLYStickerFilter {
        return IMGLYStickerFilter()
    }

    /**
    Creates a crop filter.

    - returns: A crop filter
    */
    public class func orientationCropFilter() -> IMGLYOrientationCropFilter {
        return IMGLYOrientationCropFilter()
    }

    /**
    Creates a tiltshift filter.

    - returns: A tiltshift filter.
    */
    public class func tiltShiftFilter() -> IMGLYTiltshiftFilter {
        return IMGLYTiltshiftFilter()
    }

    /**
    Creates a color-adjustment filter.

    - returns: A color-adjustment filter.
    */
    public class func colorAdjustmentFilter() -> IMGLYContrastBrightnessSaturationFilter {
        return IMGLYContrastBrightnessSaturationFilter()
    }

    /**
    Creates an enhancement filter.

    - returns: A enhancement filter.
    */
    public class func enhancementFilter() -> IMGLYEnhancementFilter {
        return IMGLYEnhancementFilter()
    }

    /**
    Creates an scale filter.

    - returns: A scale filter.
    */
    public class func scaleFilter() -> IMGLYScaleFilter {
        return IMGLYScaleFilter()
    }

    /**
    Returns the list of filters, that should be available in the dialogs.
    Change this list to select the set of filters you want to present to the user.
    - returns: An array of filter types.
    */
    public class var availableFilterList: [IMGLYFilterType] {
        return [
            .None,
            .K1,
            .K2,
            .K6,
            .KDynamic,
            .Fridge,
            .Breeze,
            .Orchid,
            .Chest,
            .Front,
            .Fixie,
            .X400,
            .BW,
            .AD1920,
            .Lenin,
            .Quozi,
            .Pola669,
            .PolaSX,
            .Food,
            .Glam,
            .Celsius,
            .Texas,
            .Lomo,
            .Goblin,
            .Sin,
            .Mellow,
            .Soft,
            .Blues,
            .Elder,
            .Sunset,
            .Evening,
            .Steel,
            .Seventies,
            .HighContrast,
            .BlueShadows,
            .Highcarb,
            .Eighties,
            .Colorful,
            .Lomo100,
            .Pro400,
            .Twilight,
            .CottonCandy,
            .Pale,
            .Settled,
            .Cool,
            .Litho,
            .Ancient,
            .Pitched,
            .Lucid,
            .Creamy,
            .Keen,
            .Tender,
            .Bleached,
            .BleachedBlue,
            .Fall,
            .Winter,
            .SepiaHigh,
            .Summer,
            .Classic,
            .NoGreen,
            .Neat,
            .Plate
        ]
    }

    // MARK: - Font Related

    /**
    Returns a list that determins what fonts will be available within
    the text-dialog.

    - returns: An array of fontnames.
    */
    public class var availableFontsList: [String] {
        return [
            "AmericanTypewriter",
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
            "Vevey"
        ]
    }

    public class func fontImporter() -> IMGLYFontImporter {
        return IMGLYFontImporter()
    }

}
