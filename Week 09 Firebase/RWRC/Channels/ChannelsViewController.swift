/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ChannelsViewController: UITableViewController {
  private let toolbarLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 15)
    return label
  }()
  
  private let channelCellIdentifier = "chatCell"
  private var currentChannelAlertController: UIAlertController?
  
  private let database = Firestore.firestore()
  private var channelReference: CollectionReference {
    return database.collection("chats")
  }
  
  private var channels: [Channel] = []
  private var channelListener: ListenerRegistration?
  
  private var isDeletingChannels = false
  private var selectedChannels: [Channel] = []
  
  private let currentUser: User
  
  deinit {
    channelListener?.remove()
  }
  
  init(currentUser: User) {
    self.currentUser = currentUser
    super.init(style: .grouped)
    
    title = "Chats"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    clearsSelectionOnViewWillAppear = true
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: channelCellIdentifier)
    
    toolbarItems = [
      UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(customView: toolbarLabel),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonPressed)),
      UIBarButtonItem(title: "Delete", style: .plain, target: self, action:#selector(deleteButtonPressed))
    ]
    toolbarLabel.text = AppSettings.displayName
    
    channelListener = channelReference.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
      
      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isToolbarHidden = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isToolbarHidden = true
  }
  
  // MARK: - Actions
  @objc private func signOut() {
    let alertController = UIAlertController(
      title: nil,
      message: "Are you sure you want to sign out?",
      preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(cancelAction)
    
    let signOutAction = UIAlertAction(
      title: "Sign Out",
      style: .destructive) { _ in
        do {
          try Auth.auth().signOut()
        } catch {
          print("Error signing out: \(error.localizedDescription)")
        }
      }
    alertController.addAction(signOutAction)
    
    present(alertController, animated: true)
  }
  
  @objc private func addButtonPressed() {
    if !isDeletingChannels {
      let alertController = UIAlertController(title: "Create a new Chat", message: nil, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      alertController.addTextField { field in
        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        field.enablesReturnKeyAutomatically = true
        field.autocapitalizationType = .words
        field.clearButtonMode = .whileEditing
        field.placeholder = "Chat name"
        field.returnKeyType = .done
        field.tintColor = .primary
      }
      
      let createAction = UIAlertAction(
        title: "Create",
        style: .default) { _ in
          self.createChannel()
        }
      createAction.isEnabled = false
      alertController.addAction(createAction)
      alertController.preferredAction = createAction
      
      present(alertController, animated: true) {
        alertController.textFields?.first?.becomeFirstResponder()
      }
      currentChannelAlertController = alertController
    }
  }
  
  @objc private func deleteButtonPressed() {
        isDeletingChannels.toggle()
        selectedChannels.removeAll()

        // Toggle between deleting mode and regular mode
        tableView.setEditing(isDeletingChannels, animated: true)

        // Reload the table view to display delete buttons or clear them
        tableView.reloadData()
    }

  @objc private func textFieldDidChange(_ field: UITextField) {
    guard let alertController = currentChannelAlertController else {
      return
    }
    alertController.preferredAction?.isEnabled = field.hasText
  }
  
  @objc private func deleteSelectedChannels() {
         for channel in selectedChannels {
             deleteChannel(channel)
         }
         selectedChannels.removeAll()

         // Reload the table view to hide delete buttons
         tableView.reloadData()
     }

  // MARK: - Helpers
  private func createChannel() {
    guard
      let alertController = currentChannelAlertController,
      let channelName = alertController.textFields?.first?.text
    else {
      return
    }

    let channel = Channel(name: channelName)
    channelReference.addDocument(data: channel.representation) { error in
      if let error = error {
        print("Error saving chat: \(error.localizedDescription)")
      }
    }
  }

  private func addChannelToTable(_ channel: Channel) {
    if channels.contains(channel) {
      return
    }

    channels.append(channel)
    channels.sort()

    guard let index = channels.firstIndex(of: channel) else {
      return
    }
    tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }

  private func updateChannelInTable(_ channel: Channel) {
    guard let index = channels.firstIndex(of: channel) else {
      return
    }

    channels[index] = channel
    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }

  private func removeChannelFromTable(_ channel: Channel) {
    guard let index = channels.firstIndex(of: channel) else {
      return
    }

    channels.remove(at: index)
    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }
  
  private func deleteChannel(_ channel: Channel) {
      guard let channelId = channel.id else {
          return
      }
      
      let channelRef = channelReference.document(channelId)
      channelRef.delete { error in
          if let error = error {
              print("Error deleting chat: \(error.localizedDescription)")
          }
      }
  }

  private func handleDocumentChange(_ change: DocumentChange) {
    guard let channel = Channel(document: change.document) else {
      return
    }

    switch change.type {
    case .added:
      addChannelToTable(channel)
    case .modified:
      updateChannelInTable(channel)
    case .removed:
      removeChannelFromTable(channel)
    }
  }
}

// MARK: - TableViewDelegate
extension ChannelsViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return channels.count
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 55
  }
  
  

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath)
    cell.accessoryType = .disclosureIndicator
    cell.textLabel?.text = channels[indexPath.row].name
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          if isDeletingChannels {
              // In deleting mode, select/deselect channels to delete
              let channel = channels[indexPath.row]
              if selectedChannels.contains(channel) {
                  if let index = selectedChannels.firstIndex(of: channel) {
                      selectedChannels.remove(at: index)
                  }
              } else {
                  selectedChannels.append(channel)
              }
              tableView.reloadData()
          } else {
              // In regular mode, enter the chat
              let channel = channels[indexPath.row]
              let viewController = ChatViewController(user: currentUser, channel: channel)
              navigationController?.pushViewController(viewController, animated: true)
          }
      }
  // Implement tableView editing style for deleting channels
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
         if isDeletingChannels {
             return .delete
         } else {
             return .none
         }
     }
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let channel = channels[indexPath.row]
            deleteChannel(channel)
            tableView.reloadData()
        }
    }
}
