//
//  qrCodeScannerViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 01/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit
import AVFoundation

protocol qrCodeScannerViewControllerDelegate {
    func doneScanningContactInfo()
    func noAccessToCamera()
}

class qrCodeScannerViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var delegate: qrCodeScannerViewControllerDelegate?
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        stopRunning()
    }
    
    func startReadingQRCode() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        var error:NSError?
        let input: AnyObject!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if (error != nil) {
            // If any error occurs, simply log the description of it and don't continue any more.
            if let delegate = self.delegate {
                delegate.noAccessToCamera()
            }
            return
        }
        
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        // Set the input device on the capture session.
        captureSession?.addInput(input as! AVCaptureInput)
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = supportedBarCodes
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        startRunning()
        
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.filter({ $0 == metadataObj.type }).count > 0 {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds
            if metadataObj.stringValue != nil {
                //if a qr code has been found , then add a button and await user response to proceed further
                stopRunning()
                saveContact(metadataObj.stringValue)
            }
        }
    }
    
    //MARK: After QRCode Scan
    func saveContact(qrCodeString: String) {
        if isUserLoggedIn {
            retrieveScannedContactKeys(qrCodeString)
            if let scannedParticipantInformation = fetchScannedParticipantDataFromDB() {
                scannedParticipantInformation.privateKey = scannedContactPrivateKey
                scannedParticipantInfo = scannedParticipantInformation
                if let delegate = self.delegate {
                    delegate.doneScanningContactInfo()
                }
            }
            else {
                self.alertUserThatContactIsNotInDB()
            }
        }
    }
    
    //function to break down the qr string and store the value
    func retrieveScannedContactKeys(decodedUrl: String) {
        let startIndex = decodedUrl.startIndex
        let midIndex = advance(decodedUrl.startIndex,8)
        let endIndex = decodedUrl.endIndex
        scannedContactPublicKey = decodedUrl[startIndex..<midIndex]
        scannedContactPrivateKey = decodedUrl[midIndex..<endIndex]
    }
    
    func fetchScannedParticipantDataFromDB() -> ParticipantsInformation? {
        for participant in allParticipantsInfo {
            if scannedContactPublicKey == participant.publicKey {
                return participant
            }
        }
        return nil
    }
    
    private func alertUserThatContactIsNotInDB() {
        let scanFailedAlert = UIAlertController(title: "Contact Scan Failed", message: "The scanned contact is not present in the database.Maybe you have selected the wrong event", preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            self.startRunning()
        }
        scanFailedAlert.addAction(dismissAction)
        self.presentViewController(scanFailedAlert, animated: true, completion: nil)
    }
    
    func stopRunning() {
        captureSession?.stopRunning()
    }
    
    func startRunning() {
        captureSession?.startRunning()
    }

}
