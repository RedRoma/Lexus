//
//  PinnedViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 10/12/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import AromaSwiftClient
import Foundation
import LexisDatabase
import UIKit

class PinnedViewController: UITableViewController
{
    
    fileprivate var favoriteWords: [LexisWord] = []
    
    fileprivate var noFavoriteWords: Bool { return favoriteWords.isEmpty }
    private let async = OperationQueue()
    private let main = OperationQueue.main
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        loadFavorites()
        
        AromaClient.sendLowPriorityMessage(withTitle: "Pinned Items Viewed")
    }
    
    func loadFavorites()
    {
        showNetworkIndicator()
        
        async.addOperation {
            
            self.favoriteWords = Settings.instance.favoriteWords
            
            AromaClient.beginMessage(withTitle: "Pinned Words Loaded")
                .addBody("\(self.favoriteWords.count) pinned words loaded")
                .withPriority(.low)
                .send()
            
            self.main.addOperation {
                self.reloadSection(0)
                self.hideNetworkIndicator()
            }
        }
        
        
        
    }
}

//MARK: Table View Data Source Methods
extension PinnedViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if noFavoriteWords
        {
            return 1
        }
        else
        {
            return favoriteWords.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let emptyCell = UITableViewCell()
        
        if noFavoriteWords
        {
            return tableView.dequeueReusableCell(withIdentifier: "NoFavoritesCell", for: indexPath)
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell") as? FavoriteWordCell else
        {
            LOG.error("Failed to dequeue FavoriteWordsCell")
            return emptyCell
        }
        
        let row = indexPath.row
        guard row >= 0 && row < favoriteWords.count else { return emptyCell }
        
        let word = favoriteWords[row]
        guard let firstForm = word.forms.first else { return emptyCell }
        
        cell.wordLabel.text = firstForm
        cell.wordInformationLabel.text = word.wordTypeInfo.lowercased()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return noFavoriteWords ? 300 : 100
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
}

//MARK: Table View Delegate Methods
extension PinnedViewController
{
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if noFavoriteWords
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
    
        let delete = UITableViewRowAction(style: .destructive, title: "Remove", handler: self.removeWord)
        
        return [delete]
        
    }
    
    private func removeWord(action: UITableViewRowAction, path: IndexPath)
    {
        let row = path.row
        guard row >= 0 && row < favoriteWords.count else { return }
        
        let wordToRemove = favoriteWords[row]
        Settings.instance.removeFavoriteWord(wordToRemove)
        
        self.favoriteWords.removeObject(wordToRemove)
        
        if noFavoriteWords
        {
            self.tableView.reloadRows(at: [path], with: .automatic)
        }
        else
        {
            self.tableView.deleteRows(at: [path], with: .automatic)
        }
        
        AromaClient.sendMediumPriorityMessage(withTitle: "Favorite Removed", withBody: "\(wordToRemove)")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let row = indexPath.row
        guard row >= 0 && row < favoriteWords.count else { return }
        let word = favoriteWords[row]
        
        guard let tabBar = self.tabBarController else { return }
        guard let tabViews = tabBar.viewControllers, tabViews.count >= 1 else { return }
        
        let wordViewControllerIndex = 0
        
        guard let wordViewNavController = tabViews[wordViewControllerIndex] as? UINavigationController,
              wordViewNavController.viewControllers.notEmpty
        else { return }
        
        guard let wordViewController = wordViewNavController.viewControllers.first(where: { $0 is WordViewController } ) as? WordViewController
        else
        {
            return
        }
        
        wordViewController.word = word
        wordViewController.tableView.reloadData()

        tabBar.selectedIndex = wordViewControllerIndex
    }
}
