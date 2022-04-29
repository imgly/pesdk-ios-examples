import Foundation
import PhotoEditorSDK

class AnnotationListSectionController: MenuListSectionController {
  private var annotationMenuItem: AnnotationMenuItem?

  /// :nodoc:
  open override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = super.cellForItem(at: index) as? MenuCollectionViewCell,
          let annotationMenuItem = annotationMenuItem else {
      fatalError()
    }

    cell.iconImageView.image = UIImage(color: annotationMenuItem.color, size: CGSize(width: 44, height: 44), cornerRadius: 22)
    cell.captionTextLabel.text = annotationMenuItem.title

    return cell
  }

  /// :nodoc:
  open override func didUpdate(to object: Any) {
    super.didUpdate(to: object)

    if let annotationMenuItem = object as? AnnotationMenuItem {
      self.annotationMenuItem = annotationMenuItem
    }
  }
}

class AnnotationMenuItem: NSObject, MenuItem {
  let title: String
  let color: UIColor
  let hardness: CGFloat
  let size: CGFloat

  init(title: String, color: UIColor, hardness: CGFloat, size: CGFloat) {
    self.title = title
    self.color = color
    self.hardness = hardness
    self.size = size
    super.init()
  }

  var diffIdentifier: NSObjectProtocol {
    self
  }

  func isEqual(toDiffableObject object: Diffable?) -> Bool {
    guard self !== object else { return true }
    guard let object = object as? AnnotationMenuItem else { return false }

    return title == object.title
      && color == object.color
      && hardness == object.hardness
      && size == object.size
  }

  static var sectionControllerType: MenuListSectionController.Type {
    AnnotationListSectionController.self
  }
}

class CustomToolController: BrushToolController {

  override func viewDidLoad() {
    menuViewController.menuItems = [
      AnnotationMenuItem(title: "Highlight", color: UIColor.yellow, hardness: 0.5, size: 20),
      AnnotationMenuItem(title: "White Out", color: UIColor.white, hardness: 0.6, size: 5),
      AnnotationMenuItem(title: "Black Pen", color: UIColor.black, hardness: 0.7, size: 10),
      AnnotationMenuItem(title: "Blue Pen", color: UIColor.blue, hardness: 0.8, size: 50),
      AnnotationMenuItem(title: "Red Pen", color: UIColor.red, hardness: 0.9, size: 1),
      AnnotationMenuItem(title: "Custom", color: UIColor.white, hardness: 1, size: 1)
    ]
    menuViewController.reloadData(completion: nil)
    brushEditController.sliderEditController.slider.neutralValue = 1
    brushEditController.sliderEditController.slider.maximumValue = 100
    brushEditController.sliderEditController.slider.minimumValue = 1
    brushEditController.activeBrushTool = .size

    super.viewDidLoad()
  }

  override func configureToolbarItem() {
    super.configureToolbarItem()

    guard let toolbarItem = toolbarItem as? DefaultToolbarItem else {
      return
    }

    toolbarItem.titleLabel.attributedText = NSAttributedString(
      string: "ANNOTATION",
      attributes: [
        .kern: 1.2,
        .font: UIFont.systemFont(ofSize: 12, weight: .medium)
      ]
    )
  }

  override func menuViewController(_ menuViewController: MenuViewController, didSelect menuItem: MenuItem) {
    guard let menuItem = menuItem as? AnnotationMenuItem else {
      return
    }

    if menuItem.title == "Custom" {
      let brushToolController = BrushToolController(configuration: configuration, productType: .pesdk)!
      notifySubscribers { $0.photoEditToolController(self, wantsToPresent: brushToolController) }
    } else {
      brushEditController.hardness = menuItem.hardness
      brushEditController.color = menuItem.color
      brushEditController.size = menuItem.size
      brushEditController.sliderEditController.slider.value = menuItem.size
    }

    super.menuViewController(menuViewController, didSelect: menuItem)
  }
}

extension UIImage {
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerRadius: CGFloat = 0.0) {
    let rect = CGRect(origin: .zero, size: size)
    let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    path.fill()
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
  }
}
