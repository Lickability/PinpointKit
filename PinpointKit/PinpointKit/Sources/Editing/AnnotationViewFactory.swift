// A factory that constructs `AnnotationView`s.
struct AnnotationViewFactory {
    let image: QuartzCore.CGImage?
    let currentLocation: CGPoint
    let tool: Tool
    let strokeColor: UIColor
    
    func annotationView() -> AnnotationView {
        switch tool {
        case .Arrow:
            let view = ArrowAnnotationView()
            view.annotation = ArrowAnnotation(startLocation: currentLocation, endLocation: currentLocation, strokeColor: strokeColor)
            return view
        case .Box:
            let view = BoxAnnotationView()
            view.annotation = BoxAnnotation(startLocation: currentLocation, endLocation: currentLocation, strokeColor: strokeColor)
            return view
        case .Text:
            let view = TextAnnotationView()
            let minimumSize = TextAnnotationView.minimumTextSize()
            let endLocation = CGPoint(x: currentLocation.x + minimumSize.width, y: currentLocation.y + minimumSize.height)
            view.annotation = Annotation(startLocation: currentLocation, endLocation: endLocation, strokeColor: strokeColor)
            return view
        case .Blur:
            let view = BlurAnnotationView()
            view.drawsBorder = true
            
            if let image = image {
                let CIImage = CoreImage.CIImage(CGImage: image)
                view.annotation = BlurAnnotation(startLocation: currentLocation, endLocation: currentLocation, image: CIImage)
            }
            
            return view
        }
    }
}
