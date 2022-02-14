//
//  AddItemViewControllerDelegate.swift
//  Checklists
//
//  Created by Victor Rubenko on 14.02.2022.
//

protocol AddItemViewControllerDelegate: AnyObject {
    func addItemViewControllerDidCancel(_ controller: AddItemViewController)
    func addItemViewController(_ controller: AddItemViewController, didFinishAdding item: ChecklistItem)
}
