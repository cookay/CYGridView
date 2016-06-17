//
//  CYGridView.swift
//  Pods
//
//  Created by zhangxi on 2016/6/16.
//
//

import UIKit

public class CYGridView: UIView {
    // MARK: - Types and Consts
    typealias Box = (view: UIView, from: NSIndexPath, to: NSIndexPath)
    
    // MARK: - Properties
    private var cachedBoxSize: CGSize?
    private var cachedBoxFrames = Dictionary<NSIndexPath, CGRect>()
    private var managedBoxs = Array<Box>()
    
    public let contentInset: UIEdgeInsets
    public let vBoxSpace: CGFloat
    public let hBoxSpace: CGFloat
    public let vBoxCount: Int
    public let hBoxCount: Int
    
    // MARK: - I/F
    
    public init(frame: CGRect, contentInset: UIEdgeInsets, vBoxSpace: CGFloat, hBoxSpace: CGFloat, vBoxCount: Int, hBoxCount: Int) {
        self.contentInset = contentInset
        self.vBoxSpace = vBoxSpace
        self.hBoxSpace = hBoxSpace
        self.vBoxCount = vBoxCount
        self.hBoxCount = hBoxCount
        
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func contentFrame() -> CGRect {
        let origin = CGPoint(x: self.contentInset.left, y: self.contentInset.top)
        let width = self.frame.width - self.contentInset.left - self.contentInset.right
        let height = self.frame.height - self.contentInset.top - self.contentInset.bottom
        let size = CGSize(width: width, height: height)
        return CGRect(origin: origin, size: size)
    }
    
    public func boxSize() -> CGSize {
        return self.cachedBoxSize ?? {
            let contentSize = self.contentFrame().size
            let width = (contentSize.width - self.hBoxSpace * CGFloat(self.hBoxCount - 1)) / CGFloat(self.hBoxCount)
            let height = (contentSize.height - self.vBoxSpace * CGFloat(self.vBoxCount - 1)) / CGFloat(self.vBoxCount)
            return CGSize(width: width, height: height)
            } ()
    }
    
    public func isValid(indexPath indexPath: NSIndexPath) -> Bool {
        return (0..<self.hBoxCount).contains(indexPath.x) && (0..<self.vBoxCount).contains(indexPath.y)
    }
    
    public func boxFrame(at indexPath: NSIndexPath) -> CGRect? {
        return self.cachedBoxFrames[indexPath] ?? {
            guard self.isValid(indexPath: indexPath) else {
                return nil
            }
            
            let originX = self.contentInset.left + (self.boxSize().width + self.hBoxSpace) * CGFloat(indexPath.x)
            let originY = self.contentInset.top + (self.boxSize().height + self.vBoxSpace) * CGFloat(indexPath.y)
            let origin = CGPoint(x: originX, y: originY)
            let frame = CGRect(origin: origin, size: self.boxSize())
            self.cachedBoxFrames[indexPath] = frame
            return frame
            }()
    }
    
    public func boxFrame(from fromIndexPath: NSIndexPath, to toIndexPath: NSIndexPath? = nil) -> CGRect? {
        let toIndexPath = toIndexPath ?? fromIndexPath
        
        if let fromFrame = self.boxFrame(at: fromIndexPath), toFrame = self.boxFrame(at: toIndexPath) {
            return CGRectUnion(fromFrame, toFrame)
        } else {
            return nil
        }
    }
    
    public func isManaged(view: UIView) -> Bool {
        return self.managedBoxs.contains {
            return $0.view == view
        }
    }
    
    public func addManaged(view view: UIView, from fromIndexPath: NSIndexPath, to toIndexPath: NSIndexPath? = nil) -> Bool {
        guard !self.isManaged(view) else {
            return false
        }
        guard let frame = self.boxFrame(from: fromIndexPath, to: toIndexPath) else {
            return false
        }
        
        let toIndexPath = toIndexPath ?? fromIndexPath
        
        self.addSubview(view)
        view.frame = frame
        self.managedBoxs.append(Box(view: view, from: fromIndexPath, to: toIndexPath))
        
        return true
    }
    
    public func removeManaged(view view: UIView) -> Bool {
        guard self.isManaged(view) else {
            return false
        }
        
        let boxIndex = self.managedBoxs.indexOf {
            return $0.view == view
        }
        
        view.removeFromSuperview()
        self.managedBoxs.removeAtIndex(boxIndex!)
        return true
    }
    
    public func invalidateLayout() {
        self.cachedBoxSize = nil
        self.cachedBoxFrames.removeAll()
    }
    
    public func clearManagedViews() {
        for box in self.managedBoxs {
            self.removeManaged(view: box.view)
        }
    }
    
    // MARK: - Life Cycle
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.invalidateLayout()
        
        for box in self.managedBoxs {
            box.view.frame = self.boxFrame(from: box.from, to: box.to) ?? CGRectZero
        }
    }
    
}