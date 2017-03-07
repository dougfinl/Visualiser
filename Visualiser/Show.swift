//
//  Show.swift
//  Visualiser
//
//  Created by Douglas Finlay on 17/02/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

class Show: NSDocument {
    
    var stage = Stage()
    
    var documentFileWrapper: FileWrapper?
    
    private static let StageFileName = "stage.json"
    private static let CameraFileName = "camera.json"
    private static let MeshesDirName = "meshes"
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    
    override class func autosavesInPlace() -> Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
    }
    
    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        if self.documentFileWrapper == nil {
            self.documentFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
        }
        
        let fileWrappers = self.documentFileWrapper!.fileWrappers!
        
        if fileWrappers[Show.StageFileName] == nil {
            let stageJSON = self.stage.json()
            let jsonData = try JSONSerialization.data(withJSONObject: stageJSON, options: [.prettyPrinted])
            
            let stageFileWrapper = FileWrapper(regularFileWithContents: jsonData)
            stageFileWrapper.preferredFilename = Show.StageFileName
            
            self.documentFileWrapper!.addFileWrapper(stageFileWrapper)
        }
        
        if fileWrappers[Show.CameraFileName] == nil {
            let cameraFileWrapper = FileWrapper(regularFileWithContents: Data())
            cameraFileWrapper.preferredFilename = Show.CameraFileName
            
            self.documentFileWrapper!.addFileWrapper(cameraFileWrapper)
        }
        
        if fileWrappers[Show.MeshesDirName] == nil {
            let meshesFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
            meshesFileWrapper.preferredFilename = Show.MeshesDirName
            
            self.documentFileWrapper!.addFileWrapper(meshesFileWrapper)
        }
        
        return self.documentFileWrapper!
    }
    
    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        guard let fileWrappers = fileWrapper.fileWrappers else {
            Swift.print("ERROR: corrupt show file")
            return
        }
        
        if let stageFileWrapper = fileWrappers[Show.StageFileName] {
            let stageJSON = try JSONSerialization.jsonObject(with: stageFileWrapper.regularFileContents!, options: []) as! [String : Any]
            
            let loadedStage = try Stage(json: stageJSON)
            self.stage = loadedStage
            
            for m in loadedStage.models {
                Swift.print(m.name)
            }
        }
    }
    
}
