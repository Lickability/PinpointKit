import UIKit
import Photos
import CoreImage

public final class EditImageViewController: UIViewController, UIGestureRecognizerDelegate, Editor {
    static let TextViewEditingBarAnimationDuration = 0.25
    static let MinimumAnnotationsNeededToPromptBeforeDismissal = 3
    
    // Defaults to true since all compositions comes from the Photo Library to start.
    private var hasACopyOfCurrentComposition: Bool = true
    
    private var hasSavedOrSharedAnyComposion: Bool = false
    
    // MARK: - Types
    
    private enum Tool: Int {
        case Arrow
        case Box
        case Text
        case Blur
        
        var name: String {
            switch self {
            case .Arrow:
                return "Arrow Tool"
            case .Box:
                return "Box Tool"
            case .Text:
                return "Text Tool"
            case .Blur:
                return "Blur Tool"
            }
        }
        
        var image: UIImage {
            let bundle = NSBundle.pinpointKitBundle()
            
            func loadImage() -> UIImage? {
                switch self {
                case .Arrow:
                    return UIImage(named: "ArrowIcon", inBundle: bundle, compatibleWithTraitCollection: nil)
                case .Box:
                    return UIImage(named: "BoxIcon", inBundle: bundle, compatibleWithTraitCollection: nil)
                case .Text:
                    return UIImage()
                case .Blur:
                    return UIImage(named: "BlurIcon", inBundle: bundle, compatibleWithTraitCollection: nil)
                }
            }
            
            return loadImage() ?? UIImage()
        }
        
        var segmentedControlItem: AnyObject {
            switch self {
            case .Arrow, .Box, .Blur:
                let image = self.image
                image.accessibilityLabel = self.name
                return image
            case .Text:
                return NSLocalizedString("Aa", comment: "The text tool’s button label.")
            }
        }
    }
    
    
    // MARK: - Properties
    
    private lazy var segmentedControl: UISegmentedControl = { [unowned self] in
        let segmentArray = [Tool.Arrow, Tool.Box, Tool.Text, Tool.Blur]
        
        let view = UISegmentedControl(items: segmentArray.map({ $0.segmentedControlItem }))
        view.selectedSegmentIndex = 0
        
        let textToolIndex = segmentArray.indexOf(Tool.Text)
        
        let segment = view.subviews[textToolIndex!]
        segment.accessibilityLabel = "Text Tool"
        
        view.setTitleTextAttributes([NSFontAttributeName: UIFont.sourceSansProFontOfSize(18, weight: .Regular)], forState: UIControlState.Normal)
        
        for i in 0..<view.numberOfSegments {
            view.setWidth(54, forSegmentAtIndex: i)
        }
        
        view.addTarget(self, action: "toolChanged:", forControlEvents: .ValueChanged)
        
        return view
        }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let annotationsView: AnnotationsView = {
        let view = AnnotationsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var shouldPromptBeforeDismissal: Bool {
        return !hasACopyOfCurrentComposition && self.annotationsView.subviews.count >= self.dynamicType.MinimumAnnotationsNeededToPromptBeforeDismissal
    }
    
    private var createAnnotationPanGestureRecognizer: UIPanGestureRecognizer! = nil
    private var updateAnnotationPanGestureRecognizer: UIPanGestureRecognizer! = nil
    private var createOrUpdateAnnotationTapGestureRecognizer: UITapGestureRecognizer! = nil
    private var updateAnnotationPinchGestureRecognizer: UIPinchGestureRecognizer! = nil
    private var touchDownGestureRecognizer: UILongPressGestureRecognizer! = nil
    
    private var previousUpdateAnnotationPinchScale: CGFloat = 1
    private var previousUpdateAnnotationPanGestureRecognizerLocation: CGPoint!
    
    private let keyboardAvoider: KeyboardAvoider = KeyboardAvoider(window: UIApplication.sharedApplication().keyWindow)
    private lazy var shareBarButtonItem: UIBarButtonItem = { [unowned self] in
        UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareImage:")
        }()
    
    private lazy var closeBarButtonItem: UIBarButtonItem = { [unowned self] in
        UIBarButtonItem(image: UIImage(named: "CloseButtonX"), landscapeImagePhone: nil, style: .Plain, target: self, action: "closeButtonTapped:")
        }()
    
    private var currentTool: Tool {
        return Tool(rawValue: segmentedControl.selectedSegmentIndex)!
    }
    
    private var currentAnnotationView: AnnotationView? {
        didSet {
            if let oldTextAnnotationView = oldValue as? TextAnnotationView {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidEndEditingNotification, object: oldTextAnnotationView.textView)
            }
            
            if let currentTextAnnotationView = currentTextAnnotationView {
                keyboardAvoider.triggerViews = [currentTextAnnotationView.textView]
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "forceEndEditingTextView", name: UITextViewTextDidEndEditingNotification, object: currentTextAnnotationView.textView)
            }
        }
    }
    
    private var currentTextAnnotationView: TextAnnotationView? {
        return currentAnnotationView as? TextAnnotationView
    }
    
    private var currentBlurAnnotationView: BlurAnnotationView? {
        return currentAnnotationView as? BlurAnnotationView
    }
    
    private var selectedAnnotationView: AnnotationView?
    
    private(set) public var currentViewModel: AssetViewModel?
    
    
    // MARK: - Initializers
    convenience init() {
        self.init(image: nil, currentViewModel: nil)
    }
    
    override convenience init(nibName: String?, bundle nibBundle: NSBundle?) {
        self.init(image: nil, currentViewModel: nil)
    }
    
    public init(image: UIImage?, currentViewModel: AssetViewModel?) {
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.leftBarButtonItem = closeBarButtonItem
        
        navigationItem.rightBarButtonItem = shareBarButtonItem
        navigationItem.titleView = segmentedControl
        
        touchDownGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleTouchDownGestureRecognizer:")
        touchDownGestureRecognizer.minimumPressDuration = 0.0;
        touchDownGestureRecognizer.delegate = self
        
        createAnnotationPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleCreateAnnotationGestureRecognizer:")
        createAnnotationPanGestureRecognizer.maximumNumberOfTouches = 1
        createAnnotationPanGestureRecognizer.delegate = self
        
        updateAnnotationPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleUpdateAnnotationGestureRecognizer:")
        updateAnnotationPanGestureRecognizer.maximumNumberOfTouches = 1
        updateAnnotationPanGestureRecognizer.delegate = self
        
        createOrUpdateAnnotationTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleUpdateAnnotationTapGestureRecognizer:")
        createOrUpdateAnnotationTapGestureRecognizer.delegate = self
        
        updateAnnotationPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handleUpdateAnnotationPinchGestureRecognizer:")
        updateAnnotationPinchGestureRecognizer.delegate = self
        
        imageView.image = image
        
        annotationsView.isAccessibilityElement = true
        annotationsView.accessibilityTraits = annotationsView.accessibilityTraits | UIAccessibilityTraitAllowsDirectInteraction;
        
        closeBarButtonItem.accessibilityLabel = "Close"
        
        if let currentViewModel = currentViewModel {
            self.currentViewModel = currentViewModel
            currentViewModel.requestImage { [weak self] in self?.imageView.image = $0 }
        }
       
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        createAnnotationPanGestureRecognizer.delegate = nil
        updateAnnotationPanGestureRecognizer.delegate = nil
        createOrUpdateAnnotationTapGestureRecognizer.delegate = nil
        updateAnnotationPinchGestureRecognizer.delegate = nil
        touchDownGestureRecognizer.delegate = nil
    }
    
    // MARK: - UIResponder
    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        let textViewIsEditing = currentTextAnnotationView?.textView.isFirstResponder() ?? false
        return action == "deleteSelectedAnnotationView" && !textViewIsEditing
    }
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(imageView)
        view.addSubview(annotationsView)
        
        keyboardAvoider.viewsToAvoidKeyboard = [imageView, annotationsView]
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTapGestureRecognizer:")
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        
        createOrUpdateAnnotationTapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
        
        view.addGestureRecognizer(touchDownGestureRecognizer)
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        view.addGestureRecognizer(createOrUpdateAnnotationTapGestureRecognizer)
        view.addGestureRecognizer(updateAnnotationPinchGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPressGestureRecognizer:")
        longPressGestureRecognizer.minimumPressDuration = 1
        longPressGestureRecognizer.delegate = self
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        if let gestureRecognizer = createAnnotationPanGestureRecognizer {
            view.addGestureRecognizer(gestureRecognizer)
        }
        
        if let gestureRecognizer = updateAnnotationPanGestureRecognizer {
            view.addGestureRecognizer(gestureRecognizer)
        }
        
        setupConstraints()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO
        // reportEventNameAsScreenView(AnalyticsEvent(name: "Edit Image"))
        
        navigationController?.hidesBarsOnTap = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // TODO
        // BRYSoundEffectPlayer.sharedInstance().playPinpointSoundEffectWithName("navbarSlideIn", fileExtension: "aif")
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    public override func viewDidLayoutSubviews() {
        if let height = self.navigationController?.navigationBar.frame.size.height {
            var rect = annotationsView.frame
            rect.origin.y += height
            rect.size.height -= height
            annotationsView.accessibilityFrame = rect
        }
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return currentModelAssetIsLandscape() ? .Landscape : [.Portrait, .PortraitUpsideDown]
    }
    
    public override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        var landscapeOrientation = UIInterfaceOrientation.LandscapeRight
        var portraitOrientation = UIInterfaceOrientation.Portrait
        
        if (traitCollection.userInterfaceIdiom == .Pad) {
            let deviceOrientation = UIDevice.currentDevice().orientation
            landscapeOrientation = (deviceOrientation == .LandscapeRight ? .LandscapeLeft : .LandscapeRight)
            portraitOrientation = (deviceOrientation == .PortraitUpsideDown ? .PortraitUpsideDown : .Portrait)
        }
        
        return currentModelAssetIsLandscape() ? landscapeOrientation : portraitOrientation
    }
    
    // MARK: - Private
    
    // TODO - turns sharing off - this seems like a Pinpoint app only need - also it pulls in a ton of other types.

//    @objc private func shareImage(button: UIBarButtonItem) {
//        var activityItems: [AnyObject] = [ ImageActivityItemProvider(placeholderItem: view.pinpoint_screenshot) ]
//        
//        if let asset = currentViewModel?.asset {
//            activityItems.append(asset)
//        }
//        
//        let promotionTextProvider = AppPromotionTextItemProvider(placeholderItem: "")
//        activityItems.append(promotionTextProvider)
//        
//        let itunesURLProvider = iTunesURLItemProvider(withiTunesID: String(App.iTunesIdentifier))
//        activityItems.append(itunesURLProvider)
//        
//        let deleteActivity = DeleteOriginalAssetActivity()
//        let facebookMessenger = FacebookMessengerActivity()
//        let openInAppActivity = TTOpenInAppActivity(view: view, andBarButtonItem: button)
//        
//        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: [openInAppActivity, deleteActivity, facebookMessenger])
//        controller.completionWithItemsHandler = finishedSharing
//        
//        openInAppActivity.superViewController = controller
//        
//        controller.popoverPresentationController?.barButtonItem = button
//        controller.excludedActivityTypes = [ UIActivityTypeAssignToContact ]
//        presentViewController(controller, animated: true, completion: nil)
//    }
//    
//    private func finishedSharing(activityType: String?, completed: Bool, items: [AnyObject]?, error: NSError?) {
//        let finished = completed && error == nil
//        
//        if finished {
//            if activityType == DeleteOriginalAssetActivity.ActivityType {
//                // Adds a delay for the screenshots view controller to receive the change notification.
//                let delayTime = dispatch_time(DISPATCH_TIME_NOW,
//                    Int64(0.1 * Double(NSEC_PER_SEC)))
//                dispatch_after(delayTime, dispatch_get_main_queue()) {
//                    self.dismissViewControllerAnimated(true, completion: nil)
//                }
//            }
//            else {
//                hasACopyOfCurrentComposition = true
//                hasSavedOrSharedAnyComposion = true
//            }
//        }
//    }
    
    private func setupConstraints() {
        let views = [
            "imageView": imageView,
            "annotationsView": annotationsView
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[imageView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[annotationsView]|", options: [], metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[annotationsView]|", options: [], metrics: nil, views: views))
    }
    
    private func newCloseSreenshotAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Your edits to this screenshot will be lost unless you share it or save a copy.", comment: "Alert title for closing a screenshot that has annotations that hasn’t been shared."), preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Discard", comment: "Alert button title to close a screenshot and discard edits"), style: .Destructive, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
// TODO - are we going to support saving like this?
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: "Alert button title to save a copy of a composition."), style: .Default, handler: { (action) in
//            let URL = writeImageToTemporaryLocation(image: self.view.pinpoint_screenshot, fileName: "Screenshot.png")
//            
//            if let URL = URL {
//                do {
//                    try PHPhotoLibrary.sharedPhotoLibrary().performChangesAndWait({
//                        let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(URL)
//                        creationRequest?.creationDate = NSDate()
//                    })
//                } catch _ {
//                }
//            }
//            
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert button title to cancel the alert."), style: .Cancel, handler: nil))
        return alert
    }
    
    @objc private func closeButtonTapped(button: UIBarButtonItem) {
        if shouldPromptBeforeDismissal {
            let alert = newCloseSreenshotAlert()
            alert.popoverPresentationController?.barButtonItem = button
            presentViewController(alert, animated: true, completion: nil)
        }
        else {
            dismissViewControllerAnimated(true, completion: {
                // TODO I don't THINK this is needed
//                if self.hasSavedOrSharedAnyComposion && Preferences().deleteAfterSharing {
//                    self.currentViewModel?.asset.delete()
//                }
            })
        }
    }
    
    @objc private func handleTouchDownGestureRecognizer(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            let possibleAnnotationView = annotationViewWithGestureRecognizer(gestureRecognizer)
            let annotationViewIsNotBlurView = !(possibleAnnotationView is BlurAnnotationView)
            
            if let annotationView = possibleAnnotationView  {
                annotationsView.bringSubviewToFront(annotationView)
                
                if annotationViewIsNotBlurView {
                    navigationController?.barHideOnTapGestureRecognizer.failRecognizing()
                }
            }
            
            if possibleAnnotationView != currentTextAnnotationView {
                endEditingTextView()
                
                if !(possibleAnnotationView is TextAnnotationView) {
                    createOrUpdateAnnotationTapGestureRecognizer.failRecognizing()
                }
                
                // Prevents creating a new text view when swiping away from the current one.
                createAnnotationPanGestureRecognizer.failRecognizing()
                
                if annotationViewIsNotBlurView {
                    navigationController?.barHideOnTapGestureRecognizer.failRecognizing()
                }
            }
        }
    }
    
    private func annotationViewWithGestureRecognizer(gestureRecognizer: UIGestureRecognizer) -> AnnotationView? {
        let view = annotationsView
        if gestureRecognizer is UIPinchGestureRecognizer {
            var annotationViews: [AnnotationView] = []
            
            let numberOfTouches = gestureRecognizer.numberOfTouches()
            
            for index in 0..<numberOfTouches {
                if let annotationView = annotationViewInView(view, withLocation: gestureRecognizer.locationOfTouch(index, inView: view)) {
                    annotationViews.append(annotationView)
                }
            }
            
            let annotationView = annotationViews.first
            let annotationViewsFiltered = annotationViews.filter { $0 == annotationViews.first }
            
            return annotationViewsFiltered.count == numberOfTouches ? annotationView : nil
        }
        
        return annotationViewInView(view, withLocation: gestureRecognizer.locationInView(view))
    }
    
    private func annotationViewInView(view: UIView, withLocation location: CGPoint) -> AnnotationView? {
        let hitView = view.hitTest(location, withEvent: nil)
        let hitTextView = hitView as? UITextView
        let hitTextViewSuperview = hitTextView?.superview as? AnnotationView
        let hitAnnotationView = hitView as? AnnotationView
        return hitAnnotationView ?? hitTextViewSuperview
    }
    
    private func currentModelAssetIsLandscape() -> Bool {
        return currentViewModel.map {
            let asset = $0.asset
            
            let portraitPixelSize = UIScreen.mainScreen().portraitPixelSize()
            return CGFloat(asset.pixelWidth) == portraitPixelSize.height && CGFloat(asset.pixelHeight) == portraitPixelSize.width
            } ?? false
    }
    
    private func beginEditingTextView() {
        if currentTextAnnotationView != nil {
            currentTextAnnotationView?.beginEditing()
            
            let doneButton = UIBarButtonItem(doneButtonWithTarget: self, action: "endEditingTextViewIfFirstResponder")
            navigationItem.setRightBarButtonItem(doneButton, animated: true)
            navigationItem.setLeftBarButtonItem(nil, animated: true)
        }
    }
    
    @objc private func forceEndEditingTextView() {
        endEditingTextView(false)
    }
    
    @objc private func endEditingTextViewIfFirstResponder() {
        endEditingTextView(true)
    }
    
    private func endEditingTextView(checksFirstResponder: Bool = true) {
        if let textView = currentTextAnnotationView?.textView where !checksFirstResponder || textView.isFirstResponder() {
            textView.resignFirstResponder()
            
            if !textView.hasText() {
                currentTextAnnotationView?.removeFromSuperview()
            }
            
            navigationItem.setLeftBarButtonItem(closeBarButtonItem, animated: true)
            navigationItem.setRightBarButtonItem(shareBarButtonItem, animated: true)
            
            currentAnnotationView = nil
        }
    }
    
    func handleGestureRecognizerFinished() {
        hasACopyOfCurrentComposition = false
        currentBlurAnnotationView?.drawsBorder = false
        let isEditingTextView = currentTextAnnotationView?.textView.isFirstResponder() ?? false
        currentAnnotationView = isEditingTextView ? currentAnnotationView : nil
    }
    
    @objc private func toolChanged(segmentedControl: UISegmentedControl) {
        // TODO
        // BRYSoundEffectPlayer.sharedInstance().playPinpointSoundEffectWithName("annotationSegmentTap", fileExtension: "aif")
        
        endEditingTextView()
        
        // Disable the bar hiding behavior when selecting the text tool. Enable for all others.
        navigationController?.barHideOnTapGestureRecognizer.enabled = currentTool != .Text
    }
    
    // MARK: - Create annotations
    
    @objc private func handleCreateAnnotationGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            handleCreateAnnotationGestureRecognizerBegan(gestureRecognizer)
        case .Changed:
            handleCreateAnnotationGestureRecognizerChanged(gestureRecognizer)
        case .Cancelled, .Failed, .Ended:
            handleGestureRecognizerFinished()
        default:
            break
        }
    }
    
    private func handleCreateAnnotationGestureRecognizerBegan(gestureRecognizer: UIGestureRecognizer) {
        let currentLocation = gestureRecognizer.locationInView(annotationsView)
        let view: AnnotationView = {
            switch self.currentTool {
            case .Arrow:
                let view = ArrowAnnotationView()
                view.annotation = ArrowAnnotation(startLocation: currentLocation, endLocation: currentLocation)
                return view
            case .Box:
                let view = BoxAnnotationView()
                view.annotation = BoxAnnotation(startLocation: currentLocation, endLocation: currentLocation)
                return view
            case .Text:
                let view = TextAnnotationView()
                let minimumSize = TextAnnotationView.minimumTextSize()
                let endLocation = CGPoint(x: currentLocation.x + minimumSize.width, y: currentLocation.y + minimumSize.height)
                view.annotation = Annotation(startLocation: currentLocation, endLocation: endLocation)
                return view
            case .Blur:
                let CGImage: QuartzCore.CGImage? = self.imageView.image?.CGImage
                let CIImage = CGImage.map({ CoreImage.CIImage(CGImage: $0) })
                let view = BlurAnnotationView()
                view.drawsBorder = true
                view.annotation = CIImage.map({ BlurAnnotation(startLocation: currentLocation, endLocation: currentLocation, image: $0) })
                return view
            }
        }()
        
        view.frame = annotationsView.bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        annotationsView.addSubview(view)
        currentAnnotationView = view
        beginEditingTextView()
    }
    
    private func handleCreateAnnotationGestureRecognizerChanged(gestureRecognizer: UIPanGestureRecognizer) {
        let currentLocation = gestureRecognizer.locationInView(annotationsView)
        currentAnnotationView?.setSecondControlPoint(currentLocation)
    }
    
    
    // MARK: - Update annotations
    
    @objc private func handleUpdateAnnotationGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            handleUpdateAnnotationGestureRecognizerBegan(gestureRecognizer)
        case .Changed:
            handleUpdateAnnotationGestureRecognizerChanged(gestureRecognizer)
        case .Cancelled, .Failed, .Ended:
            handleGestureRecognizerFinished()
        default:
            break
        }
    }
    
    private func handleUpdateAnnotationGestureRecognizerBegan(gestureRecognizer: UIPanGestureRecognizer) {
        currentAnnotationView = annotationViewWithGestureRecognizer(gestureRecognizer)
        previousUpdateAnnotationPanGestureRecognizerLocation = gestureRecognizer.locationInView(gestureRecognizer.view)
        currentBlurAnnotationView?.drawsBorder = true
        
        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
        currentTextAnnotationView?.textView.selectedRange = NSRange()
    }
    
    private func handleUpdateAnnotationGestureRecognizerChanged(gestureRecognizer: UIPanGestureRecognizer) {
        let currentLocation = gestureRecognizer.locationInView(gestureRecognizer.view)
        let previousLocation = previousUpdateAnnotationPanGestureRecognizerLocation
        let offset = CGPoint(x: currentLocation.x - previousLocation.x, y: currentLocation.y - previousLocation.y)
        currentAnnotationView?.moveControlPoints(offset)
        previousUpdateAnnotationPanGestureRecognizerLocation = gestureRecognizer.locationInView(gestureRecognizer.view)
    }
    
    @objc private func handleUpdateAnnotationTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Ended:
            if let annotationView = annotationViewWithGestureRecognizer(gestureRecognizer) {
                currentAnnotationView = annotationView as? TextAnnotationView
                beginEditingTextView()
            } else if currentTool == .Text {
                handleCreateAnnotationGestureRecognizerBegan(gestureRecognizer)
            }
        default:
            break
        }
    }
    
    @objc private func handleUpdateAnnotationPinchGestureRecognizer(gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            handleUpdateAnnotationPinchGestureRecognizerBegan(gestureRecognizer)
        case .Changed:
            handleUpdateAnnotationPinchGestureRecognizerChanged(gestureRecognizer)
        case .Cancelled, .Failed, .Ended:
            handleGestureRecognizerFinished()
        default:
            break
        }
    }
    
    private func handleUpdateAnnotationPinchGestureRecognizerBegan(gestureRecognizer: UIPinchGestureRecognizer) {
        currentAnnotationView = annotationViewWithGestureRecognizer(gestureRecognizer)
        previousUpdateAnnotationPinchScale = 1
        currentBlurAnnotationView?.drawsBorder = true
    }
    
    private func handleUpdateAnnotationPinchGestureRecognizerChanged(gestureRecognizer: UIPinchGestureRecognizer) {
        if previousUpdateAnnotationPinchScale != 0 {
            currentAnnotationView?.scaleControlPoints(gestureRecognizer.scale / previousUpdateAnnotationPinchScale)
        }
        
        previousUpdateAnnotationPinchScale = gestureRecognizer.scale
    }
    
    // MARK: - Delete annotations
    
    @objc private func handleDoubleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        if let view = annotationViewWithGestureRecognizer(gestureRecognizer) {
            deleteAnnotationView(view, animated: true)
        }
    }
    
    @objc private func handleLongPressGestureRecognizer(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        let view = annotationViewWithGestureRecognizer(gestureRecognizer)
        let frame = view?.annotationFrame
        if view == nil || frame == nil {
            return
        }
        
        selectedAnnotationView = view
        becomeFirstResponder()
        
        let point = gestureRecognizer.locationInView(gestureRecognizer.view)
        let targetRect = CGRect(origin: point, size: CGSize())
        
        let controller = UIMenuController.sharedMenuController()
        controller.setTargetRect(targetRect, inView: view!)
        controller.menuItems = [
            UIMenuItem(title: "Delete", action: "deleteSelectedAnnotationView")
        ]
        controller.update()
        controller.setMenuVisible(true, animated: true)
    }
    
    private func deleteAnnotationView(annotationView: UIView, animated:Bool) {
        let removeAnnotationView = { () -> Void in
            self.endEditingTextView()
            annotationView.removeFromSuperview()
        }
        
        if animated {
            // TODO
            // BRYSoundEffectPlayer.sharedInstance().playPinpointSoundEffectWithName("annotationDelete", fileExtension: "aif")
            
            UIView.performSystemAnimation(.Delete, onViews: [annotationView], options: [], animations: nil, completion: { (finished: Bool) -> Void in
                removeAnnotationView()
            })
            
        }
        else {
            removeAnnotationView()
        }
    }
    
    @objc private func deleteSelectedAnnotationView() {
        if let selectedAnnotationView = selectedAnnotationView {
            deleteAnnotationView(selectedAnnotationView, animated: true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == createAnnotationPanGestureRecognizer {
            return annotationViewWithGestureRecognizer(gestureRecognizer) == nil
        }
        
        if gestureRecognizer == updateAnnotationPanGestureRecognizer {
            return annotationViewWithGestureRecognizer(gestureRecognizer) != nil
        }
        
        if gestureRecognizer == createOrUpdateAnnotationTapGestureRecognizer {
            let annotationViewExists = annotationViewWithGestureRecognizer(gestureRecognizer) != nil
            return currentTool == .Text ? true : annotationViewExists
        }
        
        if gestureRecognizer == touchDownGestureRecognizer {
            return true
        }
        
        let isEditingText = currentTextAnnotationView?.textView.isFirstResponder() ?? false
        
        return !isEditingText
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let isTouchDown = gestureRecognizer == touchDownGestureRecognizer || otherGestureRecognizer == touchDownGestureRecognizer
        let isPinch = gestureRecognizer == updateAnnotationPinchGestureRecognizer || otherGestureRecognizer == updateAnnotationPinchGestureRecognizer
        
        return isTouchDown || isPinch
    }
}
