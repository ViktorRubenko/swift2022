//
//  ListDetailViewControllerDelegate.swift
//  Checklists
//
//  Created by Victor Rubenko on 15.02.2022.
//

import Foundation


protocol ListDetailViewControllerDelegate: AnyObject {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist)
}
