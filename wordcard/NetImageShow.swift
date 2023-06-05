//
//  NetImageShow.swift
//  wordcard
//
//  Created by ldd on 2022/9/30.
//

import SwiftUI

struct NetImageShow: View {
    var body: some View {
        AsyncImage(url: URL(string: "http://pi.ldd.cool:1500/static/images/sexy/1.jpg")) {  image in
            image.resizable().scaledToFit()
        } placeholder: {
            ProgressView()
        }
    }
}

struct NetImageShow_Previews: PreviewProvider {
    static var previews: some View {
        NetImageShow()
    }
}
