//
//  InstanceFactory.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit

// TODO: Fix missing fonts

/**
  A singleton that is out to create objects. It is used within the SDK to 
  create filters, views, viewcontrollers and such.
*/
@objc(IMGLYInstanceFactory) public class InstanceFactory {
    public class var sharedInstance : InstanceFactory {
        struct Static {
            static let instance = InstanceFactory()
        }
        return Static.instance
    }
    
    /**
    Creates a response filter with the specified type.
    
    :param: type The type of the filter that should be created.
    
    :returns: A CIFilter object that realizes the desired filter.
    */
    public func effectFilterWithType(type: FilterType) -> ResponseFilter {
        switch(type) {
        case FilterType.None:
            return NoneFilter()
        case FilterType.K1:
            return K1Filter()
        case FilterType.K2:
            return K2Filter()
        case FilterType.K6:
            return K6Filter()
        case FilterType.KDynamic:
            return KDynamicFilter()
        case FilterType.Fridge:
            return FridgeFilter()
        case FilterType.Breeze:
            return BreezeFilter()
        case FilterType.Orchid:
            return OrchidFilter()
        case FilterType.Chest:
            return ChestFilter()
        case FilterType.Front:
            return FrontFilter()
        case FilterType.Fixie:
            return FixieFilter()
        case FilterType.X400:
            return X400Filter()
        case FilterType.BW:
            return BWFilter()
        case FilterType.AD1920:
            return AD1920Filter()
        case FilterType.Lenin:
            return LeninFilter()
        case FilterType.Quozi:
            return QuoziFilter()
        case FilterType.Pola669:
            return Pola669Filter()
        case FilterType.PolaSX:
            return PolaSXFilter()
        case FilterType.Food:
            return FoodFilter()
        case FilterType.Glam:
            return GlamFilter()
        case FilterType.Celsius:
            return CelsiusFilter()
        case FilterType.Texas:
            return TexasFilter()
        case FilterType.Lomo:
            return LomoFilter()
        case FilterType.Gobblin:
            return GobblinFilter()
        case FilterType.Sin:
            return SinFilter()
        case FilterType.Mellow:
            return MellowFilter()
        case FilterType.Sunny:
            return SunnyFilter()
        case FilterType.A15:
            return A15Filter()
        case FilterType.Soft:
            return SoftFilter()
        case FilterType.Blues:
            return BluesFilter()
        case FilterType.Elder:
            return ElderFilter()
        case FilterType.Sunset:
            return SunsetFilter()
        case FilterType.Evening:
            return EveningFilter()
        case FilterType.Steel:
            return SteelFilter()
        case FilterType.Seventies:
            return SeventiesFilter()
        case FilterType.HighContrast:
            return HighContrastFilter()
        case FilterType.BlueShadows:
            return BlueShadowsFilter()
        case FilterType.Highcarb:
            return HighcarbFilter()
        case FilterType.Eighties:
            return EightiesFilter()
        case FilterType.Colorful:
            return ColorfulFilter()
        case FilterType.Lomo100:
            return Lomo100Filter()
        case FilterType.Pro400:
            return Pro400Filter()
        case FilterType.Twilight:
            return TwilightFilter()
        case FilterType.CottonCandy:
            return CottonCandyFilter()
        case FilterType.Mono3200:
            return Mono3200Filter()
        case FilterType.BlissfulBlue:
            return BlissfulBlueFilter()
        case FilterType.Pale:
            return PaleFilter()
        case FilterType.Settled:
            return SettledFilter()
        case FilterType.Cool:
            return CoolFilter()
        case FilterType.Litho:
            return LithoFilter()
        case FilterType.Prelude:
            return PreludeFilter()
        case FilterType.Nepal:
            return NepalFilter()
        case FilterType.Ancient:
            return AncientFilter()
        case FilterType.Pitched:
            return PitchedFilter()
        case FilterType.Lucid:
            return LucidFilter()
        case FilterType.Creamy:
            return CreamyFilter()
        case FilterType.Keen:
            return KeenFilter()
        case FilterType.Tender:
            return TenderFilter()
        case FilterType.Bleached:
            return BleachedFilter()
        case FilterType.BleachedBlue:
            return BleachedBlueFilter()
        case FilterType.Fall:
            return FallFilter()
        case FilterType.Winter:
            return WinterFilter()
        case FilterType.SepiaHigh:
            return SepiaHighFilter()
        case FilterType.Summer:
            return SummerFilter()
        case FilterType.Classic:
            return ClassicFilter()
        case FilterType.NoGreen:
            return NoGreenFilter()
        case FilterType.Neat:
            return NeatFilter()
        case FilterType.Plate:
            return PlateFilter()
        }
    }
    
    /**
    Creates a text filter.
    
    :returns: A text filter
    */
    public func textFilter() -> TextFilter {
        return TextFilter()
    }
    
    /**
    Creates a sticker filter.
    
    :returns: A sticker filter
    */
    public func stickerFilter() -> StickerFilter {
        return StickerFilter()
    }

    /**
    Creates a crop filter.
    
    :returns: A crop filter
    */
    public func orientationCropFilter() -> OrientationCropFilter {
        return OrientationCropFilter()
    }
    
    /**
    Creates a tiltshift filter.
    
    :returns: A tiltshift filter.
    */
    public func tiltShiftFilter() -> TiltshiftFilter {
        return TiltshiftFilter()
    }
    
    /**
    Creates a color-adjustment filter.
    
    :returns: A color-adjustment filter.
    */
    public func colorAdjustmentFilter() -> ContrastBrightnessSaturationFilter {
        return ContrastBrightnessSaturationFilter()
    }
    
    /**
    Creates an enhancement filter.
    
    :returns: A enhancement filter.
    */
    public func enhancementFilter() -> EnhancementFilter {
        return EnhancementFilter()
    }
    
    /**
    Returns the list of filters, that should be available in the dialogs.
    Change this list to select the set of filters you want to present to the user.
    :returns: An array of filter types.
    */
    public var availableFilterList: [FilterType] {
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
            .Gobblin,
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
    
    // MARK: - Editor View Controllers
    
    /**
    Return the viewcontroller according to the button-type.
    This is used by the main menu.
    
    :param: type The type of the button pressed.
    
    :returns: A viewcontroller according to the button-type.
    */
    public func viewControllerForButtonType(type: MainMenuButtonType, withFixedFilterStack fixedFilterStack: FixedFilterStack) -> SubEditorViewController? {
        switch (type) {
        case MainMenuButtonType.Filter:
            return filterEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case MainMenuButtonType.Stickers:
            return stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case MainMenuButtonType.Orientation:
            return orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case MainMenuButtonType.Focus:
            return focusEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case MainMenuButtonType.Crop:
            return cropEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case MainMenuButtonType.Brightness:
            return brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case MainMenuButtonType.Contrast:
            return contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case MainMenuButtonType.Saturation:
            return saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case MainMenuButtonType.Text:
            return textEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        default:
            return nil
        }
    }
    
    public func filterEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack) -> FilterEditorViewController {
        return FilterEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack) -> StickersEditorViewController {
        return StickersEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack) -> OrientationEditorViewController {
        return OrientationEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func focusEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack) -> FocusEditorViewController {
        return FocusEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func cropEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack) -> CropEditorViewController {
        return CropEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack) -> BrightnessEditorViewController {
        return BrightnessEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack) -> ContrastEditorViewController {
        return ContrastEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack) -> SaturationEditorViewController {
        return SaturationEditorViewController(fixedFilterStack: fixedFilterStack)
    }

    public func textEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack) -> TextEditorViewController {
        return TextEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    // MARK: - Gradient Views
    
    public func circleGradientView() -> CircleGradientView {
        return CircleGradientView(frame: CGRectZero)
    }

    public func boxGradientView() -> BoxGradientView {
        return BoxGradientView(frame: CGRectZero)
    }
    
    // MARK: - Font Related
    
    /**
    Returns a list that determins what fonts will be available within
    the text-dialog.
    
    :returns: An array of fontnames.
    */
    public var availableFontsList: [String] {
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
    
    public func fontImporter() -> FontImporter {
        return FontImporter()
    }
    
    // MARK: - Helpers
    
    public func cropRectComponent() -> CropRectComponent {
        return CropRectComponent()
    }
    

}