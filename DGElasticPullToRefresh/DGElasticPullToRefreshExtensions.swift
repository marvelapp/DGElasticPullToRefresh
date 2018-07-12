/*

The MIT License (MIT)

Copyright (c) 2015 Danil Gontovnik

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import UIKit
import ObjectiveC

// MARK: -
// MARK: (NSObject) Extension

extension NSObject {

    // MARK: -
    // MARK: Vars

    fileprivate struct dg_associatedKeys {
        static var observersArray = "observers"
    }

    fileprivate var dg_observers: [[String: NSObject]] {
        get {
            if let observers = objc_getAssociatedObject(self, &dg_associatedKeys.observersArray) as? [[String: NSObject]] {
                return observers
            } else {
                let observers = [[String: NSObject]]()
                self.dg_observers = observers
                return observers
            }
        } set {
            objc_setAssociatedObject(self, &dg_associatedKeys.observersArray, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: -
    // MARK: Methods

    @objc public func dg_addObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath: observer]

        if dg_observers.index(where: { $0 == observerInfo }) == nil {
            dg_observers.append(observerInfo)
            addObserver(observer, forKeyPath: keyPath, options: .new, context: nil)
        }
    }

    @objc public func dg_removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath: observer]

        if let index = dg_observers.index(where: { $0 == observerInfo}) {
            dg_observers.remove(at: index)
            removeObserver(observer, forKeyPath: keyPath)
        }
    }

}

// MARK: -
// MARK: (UIScrollView) Extension

public extension UIScrollView {

    // MARK: -
    // MARK: Vars

    fileprivate struct dg_associatedKeys {
        static var pullToRefreshView = "pullToRefreshView"
    }

    fileprivate var _pullToRefreshView: DGElasticPullToRefreshView? {
        get {
            if let pullToRefreshView = objc_getAssociatedObject(self, &dg_associatedKeys.pullToRefreshView) as? DGElasticPullToRefreshView {
                return pullToRefreshView
            }

            return nil
        }
        set {
            objc_setAssociatedObject(self, &dg_associatedKeys.pullToRefreshView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var dg_pullToRefreshView: DGElasticPullToRefreshView! {
        get {
            if let pullToRefreshView = _pullToRefreshView {
                return pullToRefreshView
            } else {
                let pullToRefreshView = DGElasticPullToRefreshView()
                _pullToRefreshView = pullToRefreshView
                return pullToRefreshView
            }
        }
    }

    // MARK: -
    // MARK: Methods (Public)

    @objc public func dg_pullToRefreshViewExist() -> Bool {
        if (dg_pullToRefreshView.superview != nil) {
            return true
        }
        return false
    }

    @objc public func dg_addPullToRefreshWithActionHandler(_ actionHandler: @escaping () -> Void) {
        dg_addPullToRefreshWithActionHandler(actionHandler, loadingView: nil)
    }

    @objc public func dg_addPullToRefreshWithActionHandler(_ actionHandler: @escaping () -> Void, loadingView: DGElasticPullToRefreshLoadingView?) {
        isMultipleTouchEnabled = false
        panGestureRecognizer.maximumNumberOfTouches = 1

        dg_pullToRefreshView.actionHandler = actionHandler
        dg_pullToRefreshView.loadingView = loadingView
        addSubview(dg_pullToRefreshView)

        dg_pullToRefreshView.observing = true
    }

    @objc public func dg_removePullToRefresh() {
        dg_pullToRefreshView.observing = false
        dg_pullToRefreshView.actionHandler = nil
        dg_pullToRefreshView.removeFromSuperview()
    }

    @objc public func dg_setPullToRefreshBackgroundColor(_ color: UIColor) {
        dg_pullToRefreshView.backgroundColor = color
    }

    @objc public func dg_setPullToRefreshFillColor(_ color: UIColor) {
        dg_pullToRefreshView.fillColor = color
        dg_pullToRefreshView.startColor = color
        dg_pullToRefreshView.endColor = color
    }

    @objc public func dg_setPullToRefreshFillColor(_ color: UIColor, endColor: UIColor) {
        dg_pullToRefreshView.fillColor = color
        dg_pullToRefreshView.startColor = color
        dg_pullToRefreshView.endColor = endColor
    }

    @objc public func dg_stopLoading() {
        dg_pullToRefreshView.stopLoading()
    }

    func dg_stopScrollingAnimation() {
        if let superview = self.superview, let index = superview.subviews.index(where: { $0 == self }) {
            superview.insertSubview(self, at: index)
        }
    }

}

// MARK: -
// MARK: (UIView) Extension

public extension UIView {
    func dg_center(_ usePresentationLayerIfPossible: Bool) -> CGPoint {
        if usePresentationLayerIfPossible, let presentationLayer = layer.presentation() {
            // Position can be used as a center, because anchorPoint is (0.5, 0.5)
            return presentationLayer.position
        }
        return center
    }
}

// MARK: -
// MARK: (UIPanGestureRecognizer) Extension

public extension UIPanGestureRecognizer {
    func dg_resign() {
        isEnabled = false
        isEnabled = true
    }
}

// MARK: -
// MARK: (UIGestureRecognizerState) Extension

public extension UIGestureRecognizerState {
    func dg_isAnyOf(_ values: [UIGestureRecognizerState]) -> Bool {
        return values.contains(where: { $0 == self })
    }
}
