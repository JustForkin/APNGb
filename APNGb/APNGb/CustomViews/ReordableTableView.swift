//
//  ReordableTableView.swift
//  APNGb
//
//  Created by Stefan Godoroja on 1/12/17.
//  Copyright © 2017 Godoroja Stefan. All rights reserved.
//

import Cocoa

protocol ReordableTableViewDelegate {
    
    func moveRow(atIndex soureIndex: Int, toIndex destinationIndex: Int)
}

class ReordableTableView: NSTableView {
    
    var pasteboardDeclaredType: String? {
        
        didSet {
            
            if let pasteboardDeclaredType = pasteboardDeclaredType {
                self.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: pasteboardDeclaredType)])
            }
        }
    }
    
    var reorderDelegate: ReordableTableViewDelegate?

    func writeRowsWith(rowIndexes: IndexSet, to pasteboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        
        if let pasteboardDeclaredType = pasteboardDeclaredType {
            pasteboard.declareTypes([NSPasteboard.PasteboardType(rawValue: pasteboardDeclaredType)], owner: self)
            pasteboard.setData(data, forType: NSPasteboard.PasteboardType(rawValue: pasteboardDeclaredType))
        } else {
            debugPrint("\(#function): Pasteboard declared type is nil")
        }
        
        return true
    }
    
    func validateDrop(validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        if dropOperation == .above {
            return .move
        } else {
            return []
        }
    }
    
    func acceptDrop(info: NSDraggingInfo, forTableView tableView: NSTableView, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        let pasteboard = info.draggingPasteboard
        
        if let pasteboardDeclaredType = pasteboardDeclaredType {
            let pasteboardData = pasteboard.data(forType: NSPasteboard.PasteboardType(rawValue: pasteboardDeclaredType))
            
            if let pasteboardData = pasteboardData {
                
                if let rowIndexes = NSKeyedUnarchiver.unarchiveObject(with: pasteboardData) as? IndexSet {
                    var oldIndex = 0
                    var newIndex = 0
                    
                    for rowIndex in rowIndexes {
                        
                        if rowIndex < row {
                            reorderDelegate?.moveRow(atIndex: (rowIndex + oldIndex),
                                                     toIndex: (row - 1))
                            tableView.moveRow(at: rowIndex + oldIndex, to: row - 1)
                            oldIndex -= 1
                        } else {
                            reorderDelegate?.moveRow(atIndex: rowIndex,
                                                     toIndex: (row + newIndex))
                            tableView.moveRow(at: rowIndex, to: row + newIndex)
                            newIndex += 1
                        }
                    }
                }
            }
            
        } else {
            debugPrint("\(#function): Pasteboard declared type is nil")
        }
        
        return true
    }
}
