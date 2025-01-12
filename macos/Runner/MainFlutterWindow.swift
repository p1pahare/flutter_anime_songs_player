import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    self.minSize = NSSize(width: 400, height: 800)
    self.maxSize = NSSize(width: 400, height: 800)
    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
