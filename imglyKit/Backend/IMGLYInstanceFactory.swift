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
    private static let filterTypeToFilter: [IMGLYFilterType: IMGLYResponseFilter.Type] = [
        .None: IMGLYNoneFilter.self,
        .K1: IMGLYK1Filter.self,
        .K2: IMGLYK2Filter.self,
        .K6: IMGLYK6Filter.self,
        .KDynamic: IMGLYKDynamicFilter.self,
        .Fridge: IMGLYFridgeFilter.self,
        .Breeze: IMGLYBreezeFilter.self,
        .Orchid: IMGLYOrchidFilter.self,
        .Chest: IMGLYChestFilter.self,
        .Front: IMGLYFrontFilter.self,
        .Fixie: IMGLYFixieFilter.self,
        .X400: IMGLYX400Filter.self,
        .BW: IMGLYBWFilter.self,
        .AD1920: IMGLYAD1920Filter.self,
        .Lenin: IMGLYLeninFilter.self,
        .Quozi: IMGLYQuoziFilter.self,
        .Pola669: IMGLYPola669Filter.self,
        .PolaSX: IMGLYPolaSXFilter.self,
        .Food: IMGLYFoodFilter.self,
        .Glam: IMGLYGlamFilter.self,
        .Celsius: IMGLYCelsiusFilter.self,
        .Texas: IMGLYTexasFilter.self,
        .Lomo: IMGLYLomoFilter.self,
        .Goblin: IMGLYGoblinFilter.self,
        .Sin: IMGLYSinFilter.self,
        .Mellow: IMGLYMellowFilter.self,
        .Soft: IMGLYSoftFilter.self,
        .Blues: IMGLYBluesFilter.self,
        .Elder: IMGLYElderFilter.self,
        .Sunset: IMGLYSunsetFilter.self,
        .Evening: IMGLYEveningFilter.self,
        .Steel: IMGLYSteelFilter.self,
        .Seventies: IMGLYSeventiesFilter.self,
        .HighContrast: IMGLYHighContrastFilter.self,
        .BlueShadows: IMGLYBlueShadowsFilter.self,
        .Highcarb: IMGLYHighcarbFilter.self,
        .Eighties: IMGLYEightiesFilter.self,
        .Colorful: IMGLYColorfulFilter.self,
        .Lomo100: IMGLYLomo100Filter.self,
        .Pro400: IMGLYPro400Filter.self,
        .Twilight: IMGLYTwilightFilter.self,
        .CottonCandy: IMGLYCottonCandyFilter.self,
        .Pale: IMGLYPaleFilter.self,
        .Settled: IMGLYSettledFilter.self,
        .Cool: IMGLYCoolFilter.self,
        .Litho: IMGLYLithoFilter.self,
        .Ancient: IMGLYAncientFilter.self,
        .Pitched: IMGLYPitchedFilter.self,
        .Lucid: IMGLYLucidFilter.self,
        .Creamy: IMGLYCreamyFilter.self,
        .Keen: IMGLYKeenFilter.self,
        .Tender: IMGLYTenderFilter.self,
        .Bleached: IMGLYBleachedFilter.self,
        .BleachedBlue: IMGLYBleachedBlueFilter.self,
        .Fall: IMGLYFallFilter.self,
        .Winter: IMGLYWinterFilter.self,
        .SepiaHigh: IMGLYSepiaHighFilter.self,
        .Summer: IMGLYSummerFilter.self,
        .Classic: IMGLYClassicFilter.self,
        .NoGreen: IMGLYNoGreenFilter.self,
        .Neat: IMGLYNeatFilter.self,
        .Plate: IMGLYPlateFilter.self
    ]


    /**
    Creates a response filter with the specified type.

    - parameter type: The type of the filter that should be created.

    - returns: A CIFilter object that realizes the desired filter.
    */
    public class func effectFilterWithType(type: IMGLYFilterType) -> EffectFilterType {
        // swiftlint:disable force_cast
        return filterTypeToFilter[type]!.init() as! EffectFilterType
        // swiftlint:enable force_cast
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
        return Array(filterTypeToFilter.keys)
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
