//
//  ScrollEvent.swift
//  Mensa
//
//  Created by Jordan Kay on 6/5/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public enum ScrollEvent {
    case willBeginDragging
    case didScroll
    case willEndDragging(velocity: CGPoint, targetContentOffset: CGPoint)
    case didEndDecelerating
    case didEndScrollingAnimation
}
