//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Brian Josel on 3/9/15.
//  Copyright (c) 2015 Brian Josel. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    //Object that represents recorded audio filepath and title
    
    var filePathURL: NSURL!
    var title: String!
    
    init!(filePathURL: NSURL!, title: String){
        /*! @abstract Create an object from saved audio containing URL and title of file
        @param filePathURL
        the file to open
        @param title
        the the title of the file
        */
        self.filePathURL = filePathURL
        self.title = title
        
    }


}
