//
//  CYGridLayout.swift
//  Pods
//
//  Created by zhangxi on 2016/6/17.
//
//

import UIKit

extension NSLayoutConstraint {
    class func active(VFL: String, metrics: [String: NSNumber]?, views: [String: UIView]) -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(VFL, options: [NSLayoutFormatOptions(rawValue: 0)], metrics: metrics, views: views)
        NSLayoutConstraint.activateConstraints(constraints)
        return constraints
    }
}

private let metricsNameHead = "head"
private let metricsNameSpace = "space"
private let metricsNameTrail = "trail"

private let viewNameBox = "box"

@objc public class CYGridLayout: NSObject {
    // MARK: - Types and Consts
    typealias Box = (view: UIView, from: NSIndexPath, to: NSIndexPath)
    
    // MARK: - Properties
    private var cachedBoxSize: CGSize?
    private var cachedBoxFrames = Dictionary<NSIndexPath, CGRect>()
    private var managedBoxs = Array<Box>()
    private var helperColumns = Array<UIView>()
    private var helperRows = Array<UIView>()
    
    public weak var target: UIView!
    public let contentInset: UIEdgeInsets
    public let vBoxSpace: CGFloat
    public let hBoxSpace: CGFloat
    public let vBoxCount: Int
    public let hBoxCount: Int
    
    // MARK: - I/F
    
    public init(target: UIView, contentInset: UIEdgeInsets, vBoxSpace: CGFloat, hBoxSpace: CGFloat, vBoxCount: Int, hBoxCount: Int) {
        self.target = target
        self.contentInset = contentInset
        self.vBoxSpace = vBoxSpace
        self.hBoxSpace = hBoxSpace
        self.vBoxCount = vBoxCount
        self.hBoxCount = hBoxCount
        
        self.target.translatesAutoresizingMaskIntoConstraints = false
        
        super.init()
    }
    
    public func contentFrame() -> CGRect {
        let origin = CGPoint(x: self.contentInset.left, y: self.contentInset.top)
        let width = self.target.frame.width - self.contentInset.left - self.contentInset.right
        let height = self.target.frame.height - self.contentInset.top - self.contentInset.bottom
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
        
        self.target.addSubview(view)
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
    
    // MARK: - Init Views
    private func initHelperColumns() {
        for _ in 0..<self.hBoxCount {
            self.helperColumns.append(self.helperView())
        }
        
        // horizontal constraints
        do {
            let vfl: String = {
                var vfl = "|-\(metricsNameHead)"
                for column in 0..<self.hBoxCount {
                    switch column {
                    case 0:
                        vfl += "-[\(viewNameBox)0]"
                    default:
                        vfl += "-\(metricsNameSpace)-[\(viewNameBox)\(column)(==\(viewNameBox)0)]"
                    }
                }
                vfl += "-\(metricsNameTrail)-|"
                return vfl
            } ()
            
            let metrics: [String: NSNumber] = [metricsNameHead: NSNumber(double: Double(self.contentInset.left)),
                                               metricsNameSpace: NSNumber(double: Double(self.hBoxSpace)),
                                               metricsNameTrail: NSNumber(double: Double(self.contentInset.right))]
            
            let views: [String: UIView] = {
                var views = Dictionary<String, UIView>()
                for column in 0..<self.hBoxCount {
                    views["\(viewNameBox)\(column)"] = self.helperColumns[column]
                }
                return views
            } ()
            
            NSLayoutConstraint.active(vfl, metrics: metrics, views: views)
        }
        
        // vertical constraints
        do {
            for column in 0..<self.hBoxCount {
                NSLayoutConstraint.active("V:|-[\(viewNameBox)]-|", metrics: nil, views: ["\(viewNameBox)": self.helperColumns[column]])
            }
        }
    }
    
    private func initHelperRows() {
        for _ in 0..<self.vBoxCount {
            self.helperRows.append(self.helperView())
        }
        
        // vertical constraints
        do {
            let vfl: String = {
                var vfl = "V:|-\(metricsNameHead)"
                for column in 0..<self.vBoxCount {
                    switch column {
                    case 0:
                        vfl += "-[\(viewNameBox)0]"
                    default:
                        vfl += "-\(metricsNameSpace)-[\(viewNameBox)\(column)(==\(viewNameBox)0)]"
                    }
                }
                vfl += "-\(metricsNameTrail)-|"
                return vfl
            } ()
            
            let metrics: [String: NSNumber] = [metricsNameHead: NSNumber(double: Double(self.contentInset.top)),
                                               metricsNameSpace: NSNumber(double: Double(self.vBoxSpace)),
                                               metricsNameTrail: NSNumber(double: Double(self.contentInset.bottom))]
            
            let views: [String: UIView] = {
                var views = Dictionary<String, UIView>()
                for column in 0..<self.vBoxCount {
                    views["\(viewNameBox)\(column)"] = self.helperRows[column]
                }
                return views
            } ()
            
            NSLayoutConstraint.active(vfl, metrics: metrics, views: views)
        }
        
        // horizontal constraints
        do {
            for column in 0..<self.vBoxCount {
                NSLayoutConstraint.active("|-[\(viewNameBox)]-|", metrics: nil, views: ["\(viewNameBox)": self.helperRows[column]])
            }
        }
    }
    
    // MARK: - Helper
    private func helperView() -> UIView {
        let view = UIView(frame: CGRect.zero)
        //view.hidden = true
        view.backgroundColor = UIColor.redColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.target.addSubview(view)
        return view
    }
    
    public func demo() {
        self.initHelperColumns()
        self.initHelperRows()
        
        
    }
    
    
}