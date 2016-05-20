/// A delegate for the Editor.
public protocol EditorDelegate: class {
    
    /**
     A function that is called with an image just before the editor is dismissed.
     
     - parameter editor: The editor resonsible for editing the image.
     - parameter screenshot: The edited image of a screenshot, after editing is complete.
     */
    func editorWillDismiss(editor: Editor, screenshot: UIImage)
}
