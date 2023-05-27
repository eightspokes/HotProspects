//
//  MeView.swift
//  HotProspects
//
//  Created by Roman on 5/17/23.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    @State private var name = "8D31B96A-02AC-4531-976F-A455686F8FE2"
    @State private var emailAddress = "you@yoursite.com"
    @State private var qrCode = UIImage()
    //Core image context
    let context = CIContext()
    let filter  = CIFilter.qrCodeGenerator()
    
    
    func generateQRCode(from string: String) -> UIImage{
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage{
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    func updateCode(){
        qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
    }
    
    
    var body: some View {
        NavigationView{
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .font(.title)
                
                TextField("Email address", text: $emailAddress)
                    .textContentType(.emailAddress)
                    .font(.title)
                Image(uiImage: qrCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                        Button {
                            
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: qrCode)
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arror.down")
                        }
                    }
            
            }
            .navigationTitle("Your code")
            .onAppear(perform: updateCode)
            .onChange(of: name){_ in updateCode()}
            .onChange(of: emailAddress){_ in updateCode()}
        }
        
    }
}



struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
