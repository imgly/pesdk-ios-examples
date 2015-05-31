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
@objc public class IMGLYInstanceFactory {
    /**
    Creates a response filter with the specified type.
    
    :param: type The type of the filter that should be created.
    
    :returns: A CIFilter object that realizes the desired filter.
    */
    public class func effectFilterWithType(type: IMGLYFilterType) -> IMGLYResponseFilter {
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
        case IMGLYFilterType.Goblin:
            return IMGLYGoblinFilter()
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
        }
    }
    
    /**
    Creates a text filter.
    
    :returns: A text filter
    */
    public class func textFilter() -> IMGLYTextFilter {
        return IMGLYTextFilter()
    }
    
    /**
    Creates a sticker filter.
    
    :returns: A sticker filter
    */
    public class func stickerFilter() -> IMGLYStickerFilter {
        return IMGLYStickerFilter()
    }

    /**
    Creates a crop filter.
    
    :returns: A crop filter
    */
    public class func orientationCropFilter() -> IMGLYOrientationCropFilter {
        return IMGLYOrientationCropFilter()
    }
    
    /**
    Creates a tiltshift filter.
    
    :returns: A tiltshift filter.
    */
    public class func tiltShiftFilter() -> IMGLYTiltshiftFilter {
        return IMGLYTiltshiftFilter()
    }
    
    /**
    Creates a color-adjustment filter.
    
    :returns: A color-adjustment filter.
    */
    public class func colorAdjustmentFilter() -> IMGLYContrastBrightnessSaturationFilter {
        return IMGLYContrastBrightnessSaturationFilter()
    }
    
    /**
    Creates an enhancement filter.
    
    :returns: A enhancement filter.
    */
    public class func enhancementFilter() -> IMGLYEnhancementFilter {
        return IMGLYEnhancementFilter()
    }
    
    /**
    Returns the list of filters, that should be available in the dialogs.
    Change this list to select the set of filters you want to present to the user.
    :returns: An array of filter types.
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
            .Sunny,
            .A15,
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
            .Mono3200,
            .BlissfulBlue,
            .Pale,
            .Settled,
            .Cool,
            .Litho,
            .Prelude,
            .Nepal,
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
    
    :returns: An array of fontnames.
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