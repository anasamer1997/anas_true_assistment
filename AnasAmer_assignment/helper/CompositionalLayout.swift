//
//  CompositionalLayout.swift
//  CompositionalLayout
//
//

import UIKit

enum CompositionalGroupAlignment {
    case vertical
    case horizontal
}

struct CompositionalLayout {
    
    static func createItem(width: NSCollectionLayoutDimension,
                           height: NSCollectionLayoutDimension,
                           spacing: NSDirectionalEdgeInsets
    ) -> NSCollectionLayoutItem {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: width,
                                                                             heightDimension: height))
        item.contentInsets = spacing
        //        NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        return item
    }
    
    static func craeteSection(group:NSCollectionLayoutGroup,scrollingBehavor:UICollectionLayoutSectionOrthogonalScrollingBehavior,groupSpcaing:CGFloat,  contentPaddint: NSDirectionalEdgeInsets) -> NSCollectionLayoutSection{
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior =  scrollingBehavor
        section.interGroupSpacing = groupSpcaing
        
        section.contentInsets = contentPaddint
        return section
        
    }
    
    static func createGroup(alignment: CompositionalGroupAlignment,
                            width: NSCollectionLayoutDimension,
                            height: NSCollectionLayoutDimension,
                            items: [NSCollectionLayoutItem]
    ) -> NSCollectionLayoutGroup {
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: width,
                                                                                       heightDimension: height),
                                                    subitems: items)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: width,
                                                                                         heightDimension: height),
                                                      subitems: items)
        }
    }
    
    static func createGroup(alignment: CompositionalGroupAlignment,
                            width: NSCollectionLayoutDimension,
                            height: NSCollectionLayoutDimension,
                            item: NSCollectionLayoutItem,
                            count: Int
    ) -> NSCollectionLayoutGroup {
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: width,
                                                                                       heightDimension: height),
                                                    subitem: item,
                                                    count: count)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: width,
                                                                                         heightDimension: height),
                                                      subitem: item,
                                                      count: count)
        }
    }
    
    static func createCustomGroup(alignment: CompositionalGroupAlignment,
                                  width: NSCollectionLayoutDimension,
                                  height: NSCollectionLayoutDimension,
                                  item: NSCollectionLayoutItem,
                                  count: Int
    ) -> NSCollectionLayoutGroup {
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: width,
                                                                                       heightDimension: height),
                                                    subitem: item,
                                                    count: count)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: width,
                                                                                         heightDimension: height),
                                                      subitem: item,
                                                      count: count)
        }
    }
    
    
    
}
