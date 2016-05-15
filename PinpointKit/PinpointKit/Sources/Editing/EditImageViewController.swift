import UIKit
import Photos
import CoreImage

public final class EditImageViewController: UIViewController, UIGestureRecognizerDelegate, Editor {
    static let TextViewEditingBarAnimationDuration = 0.25
    static let MinimumAnnotationsNeededToPromptBeforeDismissal = 3
    
    // Defaults to true since all compositions comes from the Photo Library to start.
    private var hasACopyOfCurrentComposition: Bool = true
    
    private var hasSavedOrSharedAnyComposion: Bool = false
    
    private weak var delegate: EditImageViewControllerDelegate?
    
    public func setDelegate(delegate: EditImageViewControllerDelegate) {
        self.delegate = delegate
    }
    
    public func setScreenshot(screenshot: UIImage) {
        self.imageView.image = screenshot
    }
    
    // MARK: - Properties
    
    private lazy var segmentedControl: UISegmentedControl = { [unowned self] in
        let segmentArray = [Tool.Arrow, Tool.Box, Tool.Text, Tool.Blur]
        
        let view = UISegmentedControl(items: segmentArray.map({ $0.segmentedControlItem }))
        view.selectedSegmentIndex = 0
        
        let textToolIndex = segmentArray.indexOf(Tool.Text)
        
        if let index = textToolIndex {
            let segment = view.subviews[index]
            segment.accessibilityLabel = "Text Tool"
        }
        
        view.setTitleTextAttributes([NSFontAttributeName: UIFont.sourceSansProFontOfSize(18, weight: .Regular)], forState: UIControlState.Normal)
        
        for i in 0..<view.numberOfSegments {
            view.setWidth(54, forSegmentAtIndex: i)
        }
        
        view.addTarget(self, action: #selector(EditImageViewController.toolChanged(_:)), forControlEvents: .ValueChanged)
        
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

    
    private lazy var closeBarButtonItem: UIBarButtonItem = { [unowned self] in
        UIBarButtonItem(image: UIImage(named: "CloseButtonX", inBundle: .pinpointKitBundle(), compatibleWithTraitCollection: nil), landscapeImagePhone: nil, style: .Plain, target: self, action: #selector(EditImageViewController.closeButtonTapped(_:)))
        }()
    
    private var currentTool: Tool? {
        return Tool(rawValue: segmentedControl.selectedSegmentIndex)
    }
    
    private var currentAnnotationView: AnnotationView? {
        didSet {
            if let oldTextAnnotationView = oldValue as? TextAnnotationView {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidEndEditingNotification, object: oldTextAnnotationView.textView)
            }
            
            if let currentTextAnnotationView = currentTextAnnotationView {
                keyboardAvoider.triggerViews = [currentTextAnnotationView.textView]
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditImageViewController.forceEndEditingTextView), name: UITextViewTextDidEndEditingNotification, object: currentTextAnnotationView.textView)
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
    
    
    public func viewController() -> UIViewController {
        return self
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.leftBarButtonItem = closeBarButtonItem
        
        navigationItem.titleView = segmentedControl
        
        touchDownGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EditImageViewController.handleTouchDownGestureRecognizer(_:)))
        touchDownGestureRecognizer.minimumPressDuration = 0.0
        touchDownGestureRecognizer.delegate = self
        
        createAnnotationPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(EditImageViewController.handleCreateAnnotationGestureRecognizer(_:)))
        createAnnotationPanGestureRecognizer.maximumNumberOfTouches = 1
        createAnnotationPanGestureRecognizer.delegate = self
        
        updateAnnotationPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(EditImageViewController.handleUpdateAnnotationGestureRecognizer(_:)))
        updateAnnotationPanGestureRecognizer.maximumNumberOfTouches = 1
        updateAnnotationPanGestureRecognizer.delegate = self
        
        createOrUpdateAnnotationTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditImageViewController.handleUpdateAnnotationTapGestureRecognizer(_:)))
        createOrUpdateAnnotationTapGestureRecognizer.delegate = self
        
        updateAnnotationPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(EditImageViewController.handleUpdateAnnotationPinchGestureRecognizer(_:)))
        updateAnnotationPinchGestureRecognizer.delegate = self
        
        annotationsView.isAccessibilityElement = true
        annotationsView.accessibilityTraits = annotationsView.accessibilityTraits | UIAccessibilityTraitAllowsDirectInteraction
        
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
        return action == #selector(EditImageViewController.deleteSelectedAnnotationView) && !textViewIsEditing
    }
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(imageView.image != nil);
        assert(delegate != nil);
        
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(imageView)
        view.addSubview(annotationsView)
        
        keyboardAvoider.viewsToAvoidKeyboard = [imageView, annotationsView]
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditImageViewController.handleDoubleTapGestureRecognizer(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        
        createOrUpdateAnnotationTapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
        
        view.addGestureRecognizer(touchDownGestureRecognizer)
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        view.addGestureRecognizer(createOrUpdateAnnotationTapGestureRecognizer)
        view.addGestureRecognizer(updateAnnotationPinchGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EditImageViewController.handleLongPressGestureRecognizer(_:)))
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
        
        if traitCollection.userInterfaceIdiom == .Pad {
            let deviceOrientation = UIDevice.currentDevice().orientation
            landscapeOrientation = (deviceOrientation == .LandscapeRight ? .LandscapeLeft : .LandscapeRight)
            portraitOrientation = (deviceOrientation == .PortraitUpsideDown ? .PortraitUpsideDown : .Portrait)
        }
        
        return currentModelAssetIsLandscape() ? landscapeOrientation : portraitOrientation
    }
    
    // MARK: - Private
    
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
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert button title to cancel the alert."), style: .Cancel, handler: nil))
        return alert
    }
    
    @objc private func closeButtonTapped(button: UIBarButtonItem) {
        
        defer {
            self.delegate?.didTapCloseButton(self.view.pinpoint_screenshot)
        }
        
        if shouldPromptBeforeDismissal {
            let alert = newCloseSreenshotAlert()
            alert.popoverPresentationController?.barButtonItem = button
            presentViewController(alert, animated: true, completion: nil)
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)

        }
    }
    
    @objc private func handleTouchDownGestureRecognizer(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            let possibleAnnotationView = annotationViewWithGestureRecognizer(gestureRecognizer)
            let annotationViewIsNotBlurView = !(possibleAnnotationView is BlurAnnotationView)
            
            if let annotationView = possibleAnnotationView {
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
            
            let doneButton = UIBarButtonItem(doneButtonWithTarget: self, action: #selector(EditImageViewController.endEditingTextViewIfFirstResponder))
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
        guard let currentTool = self.currentTool else { return }
        
        let currentLocation = gestureRecognizer.locationInView(annotationsView)
        
        let factory = AnnotationViewFactory(image: self.imageView.image?.CGImage, currentLocation: currentLocation, tool: currentTool)
        
        let view: AnnotationView = factory.annotationView()
        
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
        
        guard let view = annotationViewWithGestureRecognizer(gestureRecognizer) else { return }
        
        selectedAnnotationView = view
        becomeFirstResponder()
        
        let point = gestureRecognizer.locationInView(gestureRecognizer.view)
        let targetRect = CGRect(origin: point, size: CGSize())
        
        let controller = UIMenuController.sharedMenuController()
        controller.setTargetRect(targetRect, inView: view)
        controller.menuItems = [
            UIMenuItem(title: "Delete", action: #selector(EditImageViewController.deleteSelectedAnnotationView))
        ]
        controller.update()
        controller.setMenuVisible(true, animated: true)
    }
    
    private func deleteAnnotationView(annotationView: UIView, animated: Bool) {
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
            
        } else {
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
