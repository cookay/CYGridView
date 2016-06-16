import UIKit

public extension NSIndexPath {
    public convenience init(forX x: Int, forY y: Int) {
        self.init(indexes: [x, y], length: 2)
    }
    
    public var x: Int {
        return self.indexAtPosition(0)
    }
    
    public var y: Int {
        return self.indexAtPosition(1)
    }
}

public class CYGridView: UIView {
    // MARK: - Types and Consts

    
    // MARK: - Properties
    private var cachedBoxSize: CGSize?
    private var cachedBoxFrames = Dictionary<NSIndexPath, CGRect>()
    
    public let contentInsets: UIEdgeInsets
    public let vBoxSpace: CGFloat
    public let hBoxSpace: CGFloat
    public let vBoxCount: Int
    public let hBoxCount: Int
    
    // MARK: - I/F
    
    public init(frame: CGRect, contentInsets: UIEdgeInsets, vBoxSpace: CGFloat, hBoxSpace: CGFloat, vBoxCount: Int, hBoxCount: Int) {
        self.contentInsets = contentInsets
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
        let origin = CGPoint(x: self.contentInsets.left, y: self.contentInsets.top)
        let width = self.frame.width - self.contentInsets.left - self.contentInsets.right
        let height = self.frame.height - self.contentInsets.top - self.contentInsets.bottom
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
    
    public func boxFrame(at indexPath: NSIndexPath) -> CGRect? {
        return self.cachedBoxFrames[indexPath] ?? {
            guard (0..<self.hBoxCount).contains(indexPath.x) && (0..<self.vBoxCount).contains(indexPath.y) else {
                return nil
            }
            
            let originX = self.contentInsets.left + (self.boxSize().width + self.hBoxSpace) * CGFloat(indexPath.x)
            let originY = self.contentInsets.top + (self.boxSize().height + self.vBoxSpace) * CGFloat(indexPath.y)
            let origin = CGPoint(x: originX, y: originY)
            let frame = CGRect(origin: origin, size: self.boxSize())
            self.cachedBoxFrames[indexPath] = frame
            return frame
        }()
    }
    
    public func boxFrame(from fromIndexPath: NSIndexPath, to toIndexPath: NSIndexPath) -> CGRect? {
        if let fromFrame = self.boxFrame(at: fromIndexPath), toFrame = self.boxFrame(at: toIndexPath) {
            return CGRectUnion(fromFrame, toFrame)
        } else {
            return nil
        }
    }
    
    
}