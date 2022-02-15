//
//  AddItemViewController.swift
//  Checklists
//
//  Created by Victor Rubenko on 14.02.2022.
//

import UIKit

class ListDetailViewController: UITableViewController {
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    
    var item: Checklist?
    weak var delegate: ListDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        if let itemToEdit = item {
            navigationItem.title = "Edit Checklist"
            textField.text = itemToEdit.name
            doneBarButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        nil
    }
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let itemToEdit = item {
            itemToEdit.name = textField.text!
            delegate?.listDetailViewController(self, didFinishEditing: itemToEdit)
        } else {
            delegate?.listDetailViewController(self, didFinishAdding: Checklist(name: textField.text!))
        }
    }
}

extension ListDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }
}
