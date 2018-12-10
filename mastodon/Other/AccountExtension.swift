//
//  AccountExtension.swift
//  mastodon
//
//  Created by Barrett Breshears on 12/7/18.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation


extension Account {
    
    static func addAccountToList(account:Account) {
        
        guard let accountsData = UserDefaults.standard.object(forKey: "allAccounts") as? Data, var accounts = try? PropertyListDecoder().decode(Array<Account>.self, from: accountsData) else {
            return
        }
        
        accounts.append(account)
        
        
    }
    
    static func getAccounts() -> [Account] {
        
        guard let accountsData = UserDefaults.standard.object(forKey: "allAccounts") as? Data, let accounts = try? PropertyListDecoder().decode(Array<Account>.self, from: accountsData) else {
            return [Account]()
        }
        return accounts
        
    }
    
}
