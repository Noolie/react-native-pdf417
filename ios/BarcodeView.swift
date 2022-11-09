import Foundation
import UIKit
import React

final class BarcodeView: UIView {
  
    @objc var onBarcodePress: RCTBubblingEventBlock?
    @objc var text: NSString = ""
  
    private var gestureRecognizer: UITapGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onPress))
        self.addGestureRecognizer(gestureRecognizer!)
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if(gestureRecognizer != nil){
            self.removeGestureRecognizer(gestureRecognizer!)
        }
    }
  
    override func didSetProps(_ changedProps: [String]!) {
        self.setNeedsLayout()

        if (changedProps.contains("text")){
            render()
        }
    }
  
    @objc func onPress(sender : UITapGestureRecognizer) {
        if sender.state == .ended {
            onBarcodePress?([:])
        }
    }
    
    private func render(){
        guard let barcode = generatePDF417Barcode(from: text as String) else {
          return
        }

        subviews.forEach({ $0.removeFromSuperview() })

        let imageView = UIImageView(image: barcode)
          
        //    self.addTarget(self, action: #selector(onBarcodePress), for: .touchUpInside)
          
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
    }
  
    private func generatePDF417Barcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIPDF417BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
            return UIImage(ciImage: output)
            }
        }

        return nil
    }
  
}
