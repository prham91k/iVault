//
//  QRCGenerator.swift
//  XWallet
//
//  Created by loj on 26.11.17.
//

import CoreImage
import Foundation
import UIKit


public class QRCGenerator {
    
    public static func generate(from string: String?, scale: CGFloat) -> UIImage? {
        if let filter = CIFilter(name: "CIQRCodeGenerator"),
            let data = string?.data(using: String.Encoding.ascii)
        {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel") // L(ow) M(edium) Q H(igh)
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            if let output: CIImage = filter.outputImage?.transformed(by: transform) {

                let context = CIContext(options: nil)
                if let cgImage: CGImage = context.createCGImage(output, from: output.extent) {
                    let image: UIImage? = UIImage(cgImage: cgImage)
                    return image
                }

                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
