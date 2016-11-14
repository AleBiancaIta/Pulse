//
//  TeamCollectionViewController.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class TeamCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = TeamViewDataSource.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "TeamCollectionCell", bundle: nil), forCellWithReuseIdentifier: CellReuseIdentifier.Team.teamCollectionCell)
        collectionView.delegate = self
        collectionView.dataSource = self.dataSource
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onAddButtonTap(_ sender: UIButton) {
        debugPrint("Add button tapped")
    }
}

extension TeamCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 155.0, height: 210.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // SEGUE TO EMPLOYEE DETAIL PAGE
    }
    
    
    
    
    
}
