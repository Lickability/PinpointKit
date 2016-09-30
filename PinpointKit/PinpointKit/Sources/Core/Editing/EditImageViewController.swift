//
//  EditImageViewController.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import CoreImage

/// The default view controller responsible for editing an image.
public final class EditImageViewController: UIViewController, UIGestureRecognizerDelegate {
    static let TextViewEditingBarAnimationDuration = 0.25
    static let MinimumAnnotationsNeededToPromptBeforeDismissal = 3
    
    // Defaults to true since all compositions comes from the Photo Library to start.
    private var hasACopyOfCurrentComposition: Bool = true
    
    private var hasSavedOrSharedAnyComposion: Bool = false
    
    public weak var delegate: EditorDelegate?
    
    // MARK: - InterfaceCustomizable
    
    public var interfaceCustomization: InterfaceCustomization? {
        didSet {
            guard isViewLoaded else { return }
            
            updateInterfaceCustomization()
        }
    }
    
    // MARK: - Properties
    
    private lazy var segmentedControl: UISegmentedControl = { [unowned self] in
        let segmentArray = [Tool.arrow, Tool.box, Tool.text, Tool.blur]
        
        let view = UISegmentedControl(items: segmentArray.map { $0.segmentedControlItem })
        view.selectedSegmentIndex = 0
        
        let textToolIndex = segmentArray.index(of: Tool.text)
        
        if let index = textToolIndex {
            let segment = view.subviews[index]
            segment.accessibilityLabel = "Text Tool"
        }
        
        for i in 0..<view.numberOfSegments {
            view.setWidth(54, forSegmentAt: i)
        }
        
        view.addTarget(self, action: #selector(EditImageViewController.toolChanged(_:)), for: .valueChanged)
        
        return view
        }()
    
    fileprivate let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let annotationsView: AnnotationsView = {
        let view = AnnotationsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var shouldPromptBeforeDismissal: Bool {
        return !hasACopyOfCurrentComposition && annotationsView.subviews.count >= type(of: self).MinimumAnnotationsNeededToPromptBeforeDismissal
    }
    
    private var createAnnotationPanGestureRecognizer: UIPanGestureRecognizer! = nil
    private var updateAnnotationPanGestureRecognizer: UIPanGestureRecognizer! = nil
    private var createOrUpdateAnnotationTapGestureRecognizer: UITapGestureRecognizer! = nil
    private var updateAnnotationPinchGestureRecognizer: UIPinchGestureRecognizer! = nil
    private var touchDownGestureRecognizer: UILongPressGestureRecognizer! = nil
    
    private var previousUpdateAnnotationPinchScale: CGFloat = 1
    private var previousUpdateAnnotationPanGestureRecognizerLocation: CGPoint!
    
    private lazy var keyboardAvoider: KeyboardAvoider? = {
        guard let window = UIApplication.shared.keyWindow else { assertionFailure("PinpointKit did not find a keyWindow."); return nil }
        
        return KeyboardAvoider(window: window)
    }()
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(named: "CloseButtonX", in: .pinpointKitBundle(), compatibleWith: nil), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(EditImageViewController.closeButtonTapped(_:)))
    }()
    
    private lazy var doneBarButtonItem: UIBarButtonItem = {
        guard let doneButtonFont = self.interfaceCustomization?.appearance.editorTextAnnotationDoneButtonFont else { assertionFailure(); return UIBarButtonItem() }
        guard let doneButtonTitle = self.interfaceCustomization?.interfaceText.textEditingDoneButtonTitle else { assertionFailure(); return UIBarButtonItem() }
        return UIBarButtonItem(doneButtonWithTarget: self, title: doneButtonTitle, font: doneButtonFont, action: #selector(EditImageViewController.doneButtonTapped(_:)))
    }()
    
    private var currentTool: Tool? {
        return Tool(rawValue: segmentedControl.selectedSegmentIndex)
    }
    
    private var currentAnnotationView: AnnotationView? {
        didSet {
            if let oldTextAnnotationView = oldValue as? TextAnnotationView {
                NotificationCenter.default.removeObserver(self, name: .UITextViewTextDidEndEditing, object: oldTextAnnotationView.textView)
            }
            
            if let currentTextAnnotationView = currentTextAnnotationView {
                keyboardAvoider?.triggerViews = [currentTextAnnotationView.textView]
                
                NotificationCenter.default.addObserver(self, selector: #selector(EditImageViewController.forceEndEditingTextView), name: .UITextViewTextDidEndEditing, object: currentTextAnnotationView.textView)
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
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
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
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        createAnnotationPanGestureRecognizer.delegate = nil
        updateAnnotationPanGestureRecognizer.delegate = nil
        createOrUpdateAnnotationTapGestureRecognizer.delegate = nil
        updateAnnotationPinchGestureRecognizer.delegate = nil
        touchDownGestureRecognizer.delegate = nil
    }
    
    // MARK: - UIResponder
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let textViewIsEditing = currentTextAnnotationView?.textView.isFirstResponder ?? false
        return action == #selector(EditImageViewController.deleteSelectedAnnotationView) && !textViewIsEditing
    }
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(imageView.image != nil, "A screenshot must be set using `setScreenshot(_:)` before loading the view.")
        
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(annotationsView)
        
        keyboardAvoider?.viewsToAvoidKeyboard = [imageView, annotationsView]
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditImageViewController.handleDoubleTapGestureRecognizer(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        
        createOrUpdateAnnotationTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
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
        
        updateInterfaceCustomization()
        setupConstraints()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnTap = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    public override func viewDidLayoutSubviews() {
        if let height = navigationController?.navigationBar.frame.height {
            var rect = annotationsView.frame
            rect.origin.y += height
            rect.size.height -= height
            annotationsView.accessibilityFrame = rect
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return imageIsLandscape() ? .landscape : [.portrait, .portraitUpsideDown]
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        var landscapeOrientation = UIInterfaceOrientation.landscapeRight
        var portraitOrientation = UIInterfaceOrientation.portrait
        
        if traitCollection.userInterfaceIdiom == .pad {
            let deviceOrientation = UIDevice.current.orientation
            landscapeOrientation = (deviceOrientation == .landscapeRight ? .landscapeLeft : .landscapeRight)
            portraitOrientation = (deviceOrientation == .portraitUpsideDown ? .portraitUpsideDown : .portrait)
        }
        
        return imageIsLandscape() ? landscapeOrientation : portraitOrientation
    }
    
    // MARK: - Private
    
    private func setupConstraints() {
        let views = [
            "imageView": imageView,
            "annotationsView": annotationsView
        ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[imageView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[annotationsView]|", options: [], metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[annotationsView]|", options: [], metrics: nil, views: views))
    }
    
    private func newCloseScreenshotAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Your edits to this screenshot will be lost unless you share it or save a copy.", comment: "Alert title for closing a screenshot that has annotations that hasn’t been shared."), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Discard", comment: "Alert button title to close a screenshot and discard edits"), style: .destructive) { action in
            self.delegate?.editorWillDismiss(self, with: self.view.pinpoint_screenshot)
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert button title to cancel the alert."), style: .cancel, handler: nil))
        return alert
    }
    
    @objc private func closeButtonTapped(_ button: UIBarButtonItem) {
        guard let image = imageView.image else { assertionFailure(); return }
        
        if let delegate = self.delegate {
            if delegate.editorShouldDismiss(self, with: image) {
                delegate.editorWillDismiss(self, with: image)
                
                dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func doneButtonTapped(_ button: UIBarButtonItem) {
        if let delegate = self.delegate {
            if delegate.editorShouldDismiss(self, with: self.view.pinpoint_screenshot) {
                self.delegate?.editorWillDismiss(self, with: self.view.pinpoint_screenshot)
                
                dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleTouchDownGestureRecognizer(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let possibleAnnotationView = annotationView(with: gestureRecognizer)
            let annotationViewIsNotBlurView = !(possibleAnnotationView is BlurAnnotationView)
            
            if let annotationView = possibleAnnotationView {
                annotationsView.bringSubview(toFront: annotationView)
                
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
    
    private func annotationView(with gestureRecognizer: UIGestureRecognizer) -> AnnotationView? {
        let view = annotationsView
        if gestureRecognizer is UIPinchGestureRecognizer {
            var annotationViews: [AnnotationView] = []
            
            let numberOfTouches = gestureRecognizer.numberOfTouches
            
            for index in 0..<numberOfTouches {
                if let annotationView = self.annotationView(in: view, with: gestureRecognizer.location(ofTouch: index, in: view)) {
                    annotationViews.append(annotationView)
                }
            }
            
            let annotationView = annotationViews.first
            let annotationViewsFiltered = annotationViews.filter { $0 == annotationViews.first }
            
            return annotationViewsFiltered.count == numberOfTouches ? annotationView : nil
        }
        
        return annotationView(in: view, with: gestureRecognizer.location(in: view))
    }
    
    private func annotationView(in view: UIView, with location: CGPoint) -> AnnotationView? {
        let hitView = view.hitTest(location, with: nil)
        let hitTextView = hitView as? UITextView
        let hitTextViewSuperview = hitTextView?.superview as? AnnotationView
        let hitAnnotationView = hitView as? AnnotationView
        return hitAnnotationView ?? hitTextViewSuperview
    }
    
    private func imageIsLandscape() -> Bool {
        guard let imageSize = imageView.image?.size else { return false }
        guard let imageScale = imageView.image?.scale else { return false }

        let imagePixelSize = CGSize(width: imageSize.width * imageScale, height: imageSize.height * imageScale)
        
        let portraitPixelSize = UIScreen.main.portraitPixelSize()
        return CGFloat(imagePixelSize.width) == portraitPixelSize.height && CGFloat(imagePixelSize.height) == portraitPixelSize.width
    }
    
    private func beginEditingTextView() {
        guard let currentTextAnnotationView = currentTextAnnotationView else { return }
        currentTextAnnotationView.beginEditing()
        
        guard let buttonFont = interfaceCustomization?.appearance.editorTextAnnotationDoneButtonFont else { assertionFailure(); return }
        let dismissButton = UIBarButtonItem(title: interfaceCustomization?.interfaceText.textEditingDismissButtonTitle, style: .done, target: self, action: #selector(EditImageViewController.endEditingTextViewIfFirstResponder))
        dismissButton.setTitleTextAttributes([NSFontAttributeName: buttonFont], for: UIControlState())
        
        navigationItem.setRightBarButton(dismissButton, animated: true)
        navigationItem.setLeftBarButton(nil, animated: true)
    }
    
    @objc private func forceEndEditingTextView() {
        endEditingTextView(false)
    }
    
    @objc private func endEditingTextViewIfFirstResponder() {
        endEditingTextView(true)
    }
    
    private func endEditingTextView(_ checksFirstResponder: Bool = true) {
        if let textView = currentTextAnnotationView?.textView, !checksFirstResponder || textView.isFirstResponder {
            textView.resignFirstResponder()
            
            if !textView.hasText {
                currentTextAnnotationView?.removeFromSuperview()
            }
            
            navigationItem.setRightBarButton(doneBarButtonItem, animated: true)
            
            currentAnnotationView = nil
        }
    }
    
    private func handleGestureRecognizerFinished() {
        hasACopyOfCurrentComposition = false
        currentBlurAnnotationView?.drawsBorder = false
        let isEditingTextView = currentTextAnnotationView?.textView.isFirstResponder ?? false
        currentAnnotationView = isEditingTextView ? currentAnnotationView : nil
    }
    
    @objc private func toolChanged(_ segmentedControl: UISegmentedControl) {
        endEditingTextView()
        
        // Disable the bar hiding behavior when selecting the text tool. Enable for all others.
        navigationController?.barHideOnTapGestureRecognizer.isEnabled = currentTool != .text
    }
    
    private func updateInterfaceCustomization() {
        guard let appearance = interfaceCustomization?.appearance else { assertionFailure(); return }
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: appearance.editorTextAnnotationSegmentFont], for: UIControlState())
        
        guard let annotationFont = appearance.annotationTextAttributes[NSFontAttributeName] as? UIFont else { assertionFailure(); return }
        UITextView.appearance(whenContainedInInstancesOf: [TextAnnotationView.self]).font = annotationFont
        
        if let annotationFillColor = appearance.annotationFillColor {
            annotationsView.tintColor = annotationFillColor
        }
    }
    
    // MARK: - Create annotations
    
    @objc private func handleCreateAnnotationGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            handleCreateAnnotationGestureRecognizerBegan(gestureRecognizer)
        case .changed:
            handleCreateAnnotationGestureRecognizerChanged(gestureRecognizer)
        case .cancelled, .failed, .ended:
            handleGestureRecognizerFinished()
        default:
            break
        }
    }
    
    private func handleCreateAnnotationGestureRecognizerBegan(_ gestureRecognizer: UIGestureRecognizer) {
        guard let currentTool = currentTool else { return }
        guard let annotationStrokeColor = interfaceCustomization?.appearance.annotationStrokeColor else { return }
        guard let annotationTextAttributes = interfaceCustomization?.appearance.annotationTextAttributes else { return }
        
        let currentLocation = gestureRecognizer.location(in: annotationsView)
        
        let factory = AnnotationViewFactory(image: imageView.image?.cgImage, currentLocation: currentLocation, tool: currentTool, strokeColor: annotationStrokeColor, textAttributes: annotationTextAttributes)
        
        let view: AnnotationView = factory.annotationView()
        
        view.frame = annotationsView.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        annotationsView.addSubview(view)
        currentAnnotationView = view
        beginEditingTextView()
    }
    
    private func handleCreateAnnotationGestureRecognizerChanged(_ gestureRecognizer: UIPanGestureRecognizer) {
        let currentLocation = gestureRecognizer.location(in: annotationsView)
        currentAnnotationView?.setSecondControlPoint(currentLocation)
    }
    
    // MARK: - Update annotations
    
    @objc private func handleUpdateAnnotationGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            handleUpdateAnnotationGestureRecognizerBegan(gestureRecognizer)
        case .changed:
            handleUpdateAnnotationGestureRecognizerChanged(gestureRecognizer)
        case .cancelled, .failed, .ended:
            handleGestureRecognizerFinished()
        default:
            break
        }
    }
    
    private func handleUpdateAnnotationGestureRecognizerBegan(_ gestureRecognizer: UIPanGestureRecognizer) {
        currentAnnotationView = annotationView(with: gestureRecognizer)
        previousUpdateAnnotationPanGestureRecognizerLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        currentBlurAnnotationView?.drawsBorder = true
        
        UIMenuController.shared.setMenuVisible(false, animated: true)
        currentTextAnnotationView?.textView.selectedRange = NSRange()
    }
    
    private func handleUpdateAnnotationGestureRecognizerChanged(_ gestureRecognizer: UIPanGestureRecognizer) {
        let currentLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        let previousLocation: CGPoint = previousUpdateAnnotationPanGestureRecognizerLocation
        let offset = CGPoint(x: currentLocation.x - previousLocation.x, y: currentLocation.y - previousLocation.y)
        currentAnnotationView?.move(controlPointsBy: offset)
        previousUpdateAnnotationPanGestureRecognizerLocation = gestureRecognizer.location(in: gestureRecognizer.view)
    }
    
    @objc private func handleUpdateAnnotationTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .ended:
            if let annotationView = annotationView(with: gestureRecognizer) {
                currentAnnotationView = annotationView as? TextAnnotationView
                beginEditingTextView()
            } else if currentTool == .text {
                handleCreateAnnotationGestureRecognizerBegan(gestureRecognizer)
            }
        default:
            break
        }
    }
    
    @objc private func handleUpdateAnnotationPinchGestureRecognizer(_ gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            handleUpdateAnnotationPinchGestureRecognizerBegan(gestureRecognizer)
        case .changed:
            handleUpdateAnnotationPinchGestureRecognizerChanged(gestureRecognizer)
        case .cancelled, .failed, .ended:
            handleGestureRecognizerFinished()
        default:
            break
        }
    }
    
    private func handleUpdateAnnotationPinchGestureRecognizerBegan(_ gestureRecognizer: UIPinchGestureRecognizer) {
        currentAnnotationView = annotationView(with: gestureRecognizer)
        previousUpdateAnnotationPinchScale = 1
        currentBlurAnnotationView?.drawsBorder = true
    }
    
    private func handleUpdateAnnotationPinchGestureRecognizerChanged(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if previousUpdateAnnotationPinchScale != 0 {
            currentAnnotationView?.scale(controlPointsBy: (gestureRecognizer.scale / previousUpdateAnnotationPinchScale))
        }
        
        previousUpdateAnnotationPinchScale = gestureRecognizer.scale
    }
    
    // MARK: - Delete annotations
    
    @objc private func handleDoubleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        if let view = annotationView(with: gestureRecognizer) {
            deleteAnnotationView(view, animated: true)
        }
    }
    
    @objc private func handleLongPressGestureRecognizer(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.began {
            return
        }
        
        guard let view = annotationView(with: gestureRecognizer) else { return }
        
        selectedAnnotationView = view
        becomeFirstResponder()
        
        let point = gestureRecognizer.location(in: gestureRecognizer.view)
        let targetRect = CGRect(origin: point, size: CGSize())
        
        let controller = UIMenuController.shared
        controller.setTargetRect(targetRect, in: view)
        controller.menuItems = [
            UIMenuItem(title: "Delete", action: #selector(EditImageViewController.deleteSelectedAnnotationView))
        ]
        controller.update()
        controller.setMenuVisible(true, animated: true)
    }
    
    private func deleteAnnotationView(_ annotationView: UIView, animated: Bool) {
        let removeAnnotationView = {
            self.endEditingTextView()
            annotationView.removeFromSuperview()
        }
        
        if animated {
            UIView.perform(.delete, on: [annotationView], options: [], animations: nil) { finished in
                removeAnnotationView()
            }
            
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
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == createAnnotationPanGestureRecognizer {
            return annotationView(with: gestureRecognizer) == nil
        }
        
        if gestureRecognizer == updateAnnotationPanGestureRecognizer {
            return annotationView(with: gestureRecognizer) != nil
        }
        
        if gestureRecognizer == createOrUpdateAnnotationTapGestureRecognizer {
            let annotationViewExists = annotationView(with: gestureRecognizer) != nil
            return currentTool == .text ? true : annotationViewExists
        }
        
        if gestureRecognizer == touchDownGestureRecognizer {
            return true
        }
        
        let isEditingText = currentTextAnnotationView?.textView.isFirstResponder ?? false
        
        return !isEditingText
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let isTouchDown = gestureRecognizer == touchDownGestureRecognizer || otherGestureRecognizer == touchDownGestureRecognizer
        let isPinch = gestureRecognizer == updateAnnotationPinchGestureRecognizer || otherGestureRecognizer == updateAnnotationPinchGestureRecognizer
        
        return isTouchDown || isPinch
    }
}

extension EditImageViewController: Editor {
    public func setScreenshot(_ screenshot: UIImage) {
        let oldScreenshot = imageView.image
        
        imageView.image = screenshot
        
        if screenshot != oldScreenshot {
            clearAllAnnotations()
        }
    }
    
    private func clearAllAnnotations() {
        for annotationView in annotationsView.subviews where annotationView is AnnotationView {
            annotationView.removeFromSuperview()
        }
    }
}
