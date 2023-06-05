//
//  word.swift
//  wordcard
//
//  Created by ldd on 2022/9/8.
//

import Foundation
import AVFoundation

var pronouncor: AVPlayer!

struct Cit: Decodable {
    let quote: String?
    let sound: String?
    
    init(quote: String? = nil, sound: String? = nil) {
        self.quote = quote
        self.sound = sound
    }
}

struct Sense: Decodable {
    let def: String?
    let cits: [Cit]?
    
    init(def: String? =  nil, cits: [Cit]? = nil) {
        self.def = def
        self.cits = cits
    }
}

struct WordDef: Decodable {
    var pronUrl: String?
    var senses: [Sense]?
    
    init(pronUrl: String? = nil, senses: [Sense]? = nil) {
        self.pronUrl = pronUrl
        self.senses = senses
    }
}


struct ImageList: Decodable {
    let data: [String]
}


class Word: ObservableObject {
    @Published var literal: String
    @Published var note: String
    @Published var defFromCollins: WordDef?
    @Published var defFromWebster: WordDef?
    @Published var imageUrls: [String]?
    
    var pronUrl: String? {
        defFromWebster?.pronUrl
    }
    
    init(_ literal: String, note: String = "", collinsDef: WordDef? = nil, websterDef: WordDef? = nil, imageUrls: [String]? = nil) {
        self.literal = literal.trimmingCharacters(in: .whitespaces)
        self.note = note
        self.defFromCollins = collinsDef
        self.defFromWebster = websterDef
        self.imageUrls = imageUrls
        getDefFromWebster()
    }
    
    func notValidLiteral() -> Bool {
        self.literal = self.literal.trimmingCharacters(in: .whitespaces)
        return self.literal.isEmpty
    }
    
    func resetResources() -> Void {
        self.defFromCollins = nil
        self.defFromWebster = nil
        self.imageUrls = nil
    }
    
    func getDefFromCollins() {
        if notValidLiteral() { return }
        
        let url = "http://pi.ldd.cool:1500/word/\(literal)/def/from/collins"
        httpGet(url, WordDef.self) { defs in
            print("got senses from collins....")

            DispatchQueue.main.async {
                self.defFromCollins = defs
            }
        }
    }
    
    func getDefFromWebster() {
        if notValidLiteral() { return }
        
        let url = "http://pi.ldd.cool:1500/word/\(literal)/def/from/webster"
        httpGet(url, WordDef.self) { defs in
            print("got senses from webster....")
            DispatchQueue.main.async {
                self.defFromWebster = defs
            }
        }
    }
    
    func getImages() {
        if notValidLiteral() { return }
        
        let url = "http://pi.ldd.cool:1500/word/\(literal)/images"
        print("try  to get images....from....\(url)....")
        httpGet(url, ImageList.self) { imgs in
            print(" got images ....")
            for i in imgs.data {
                print(i)
            }
            DispatchQueue.main.async {
                self.imageUrls = imgs.data
            }
        }
    }
    
    func pronounce() {
        DispatchQueue.main.async {
            if let pronUrl = self.pronUrl {
                pronouncor = AVPlayer(url: URL(string: pronUrl)!)
                pronouncor.play()
            }
        }
    }
}

func httpGet<T>(_ urlStr: String, _ type: T.Type, handler: @escaping (T) -> Void) where T: Decodable {
    let url = URL(string: urlStr)
    let task  = URLSession.shared.dataTask(with: url!) { data, response, error in
        if error != nil {
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
            return
        }
        let jsonText = String(data: data!, encoding: .utf8)!
        handler(try! JSONDecoder().decode(type, from: jsonText.data(using: .utf8)!))
    }
    task.resume()
}

extension Word {
    static let sampleWords = [
        Word("alga", note: "海藻"),
        Word("aluminum", note: "铝"),
        Word("abreast", note: "并肩地"),
        Word("commute")
    ]
}
