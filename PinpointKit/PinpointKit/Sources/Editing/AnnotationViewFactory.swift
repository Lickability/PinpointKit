// A factory that constructs `AnnotationView`s.
struct AnnotationViewFactory {
    let image: QuartzCore.CGImage?
    let currentLocation: CGPoint
    let tool: Tool
    
    func annotationView() -> AnnotationView {
        switch tool {
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
            let CIImage = image.map { CoreImage.CIImage(CGImage: $0) }
            let view = BlurAnnotationView()
            view.drawsBorder = true
            view.annotation = CIImage.map { BlurAnnotation(startLocation: currentLocation, endLocation: currentLocation, image: $0) }
            return view
        }
    }
}
