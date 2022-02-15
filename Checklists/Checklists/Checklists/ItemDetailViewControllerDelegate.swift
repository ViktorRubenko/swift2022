//
//  AddItemViewControllerDelegate.swift
//  Checklists
//
//  Created by Victor Rubenko on 14.02.2022.
//

protocol ItemDetailViewControllerDelegate: AnyObject {
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
}
