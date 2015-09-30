//
//  MasterViewController.swift
//  WordScramble
//
//  Created by Andrew  Nguyen on 9/30/15.
//  Copyright © 2015 Andrew Nguyen. All rights reserved.
//

import GameplayKit
import UIKit

class WordScrambleViewController: UITableViewController {

    var objects = [String]()
    var allWords = [String]()

    // MARK: - VC Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptForAnswer")
        if let startWordsPath = NSBundle.mainBundle().pathForResource("start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath, usedEncoding: nil) {
                allWords = startWords.componentsSeparatedByString("\n")
            } else {
                loadDefaultWords()
            }
        } else {
            loadDefaultWords()
        }
        startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Helper Functions

    func loadDefaultWords() {
        allWords = ["silkworm"]
    }

    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allWords) as! [String]
        title = allWords[0]
        objects.removeAll(keepCapacity: true)
        tableView.reloadData()
    }

    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler(nil)

        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, ac] _ in
            let answer = ac.textFields![0]
            self.submitAnswer(answer.text!)
        }
        ac.addAction(submitAction)

        presentViewController(ac, animated: true, completion: nil)
    }

    func submitAnswer(answer: String) {
        let lowerAnswer = answer.lowercaseString

        if wordIsSameAsStartWord(lowerAnswer) {
            if wordIsPossible(lowerAnswer) {
                if wordIsOriginal(lowerAnswer) {
                    if wordIsReal(lowerAnswer) {
                        objects.insert(answer, atIndex: 0)

                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

                        return
                    } else {
                        showErrorMessage("Word not recognized", errorMessage: "You can't just make them up, you know!")
                    }
                } else {
                    showErrorMessage("Word used already", errorMessage: "Be more original!")
                }
            } else {
                showErrorMessage("Word not possible", errorMessage: "You can't spell that word from '\(title!.lowercaseString)'!")
            }
        } else {
            showErrorMessage("Word is the same as start word", errorMessage: "You can't just use the same word!")
        }
    }

    func wordIsSameAsStartWord(word: String) -> Bool {
        return !(word == title!.lowercaseString)
    }

    func wordIsPossible(word: String) -> Bool {
        var tempWord = title!.lowercaseString

        for letter in word.characters {
            if let pos = tempWord.rangeOfString(String(letter)) {
                tempWord.removeAtIndex(pos.startIndex)
            } else {
                return false
            }
        }

        return true
    }

    func wordIsOriginal(word: String) -> Bool {
        return !objects.contains(word)
    }

    func wordIsReal(word: String) -> Bool {
        if word.characters.count < 3 {
            return false
        }

        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

}

