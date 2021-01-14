////
////  ActivityIndicatorView.swift
////  Tangem Tap
////
////  Created by Alexander Osokin on 20.08.2020.
////  Copyright © 2020 Tangem AG. All rights reserved.
////
//
//import SwiftUI
//
//struct RefreshableScrollView<Content: View>: UIViewRepresentable {
//    @Binding var refreshing: Bool
//    let content: () -> Content
//    let subviewTag = 12345
//    internal init(refreshing: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
//        self.content = content
//        self._refreshing = refreshing
//    }
//
//    func makeUIView(context: Context) -> UIScrollView {
//        let scrollView = UIScrollView()
//        scrollView.backgroundColor = .clear
//        scrollView.refreshControl = UIRefreshControl()
//        scrollView.delegate = context.coordinator
//        updateSubview(for: scrollView)
//        return scrollView
//    }
//
//    func updateSubview(for view: UIScrollView) {
//        view.subviews
//            .first (where:{ $0.tag == subviewTag })?
//            .removeFromSuperview()
//
//        let host = UIHostingController(rootView: content())
//        host.loadView()
//        host.view.removeConstraints(host.view.constraints)
//        host.view.tag = subviewTag
//        view.addSubview(host.view)
//        host.view.translatesAutoresizingMaskIntoConstraints = false
//        host.view.backgroundColor = .clear
//        NSLayoutConstraint.activate([
//            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            host.view.topAnchor.constraint(equalTo: view.contentLayoutGuide.topAnchor),
//            host.view.bottomAnchor.constraint(equalTo: view.contentLayoutGuide.bottomAnchor),
//            host.view.widthAnchor.constraint(equalTo: view.widthAnchor)
//        ])
//    }
//
//    func updateUIView(_ uiView: UIScrollView, context: Self.Context) {
//        if !refreshing {
//            uiView.refreshControl?.endRefreshing()
//        }
//         updateSubview(for: uiView)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, refreshing: $refreshing)
//    }
//
//    class Coordinator: NSObject, UIScrollViewDelegate {
//        var parent: RefreshableScrollView
//        @Binding var refreshing: Bool
//
//        init(_ parent: RefreshableScrollView, refreshing: Binding<Bool>) {
//            self.parent = parent
//            self._refreshing = refreshing
//        }
//
//        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//            if let refreshing = scrollView.refreshControl?.isRefreshing, refreshing == true {
//                self.refreshing = true
//            }
//        }
//    }
//}


// Authoer: The SwiftUI Lab
// Full article: https://swiftui-lab.com/scrollview-pull-to-refresh/
import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var frozen: Bool = false
    @State private var rotation: Angle = .degrees(0)
    
    var threshold: CGFloat = 80
    @Binding var refreshing: Bool
    let content: Content

    init(height: CGFloat = 80, refreshing: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.threshold = height
        self._refreshing = refreshing
        self.content = content()

    }
    
    var body: some View {
        return VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                    
                    VStack { self.content }.alignmentGuide(.top, computeValue: { d in (self.refreshing && self.frozen) ? -self.threshold : 0.0 })
                    if scrollOffset != 0 {
                        SymbolView(height: self.threshold, loading: self.refreshing, frozen: self.frozen, rotation: self.rotation)
                    }
                }
            }
            .background(FixedView())
            .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
                self.refreshLogic(values: values)
            }
        }
    }
    
    func refreshLogic(values: [RefreshableKeyTypes.PrefData]) {
        DispatchQueue.main.async {
            // Calculate scroll offset
            let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
            let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
            
            self.scrollOffset  = movingBounds.minY - fixedBounds.minY
            
            self.rotation = self.symbolRotation(self.scrollOffset)
            
            // Crossing the threshold on the way down, we start the refresh process
            if !self.refreshing && (self.scrollOffset > self.threshold && self.previousScrollOffset <= self.threshold) {
                self.refreshing = true
            }
            
            if self.refreshing {
                // Crossing the threshold on the way up, we add a space at the top of the scrollview
                if self.previousScrollOffset > self.threshold && self.scrollOffset <= self.threshold {
                    self.frozen = true

                }
            } else {
                // remove the sapce at the top of the scroll view
                self.frozen = false
            }
            
            // Update last scroll offset
            self.previousScrollOffset = self.scrollOffset
        }
    }
    
    func symbolRotation(_ scrollOffset: CGFloat) -> Angle {
        
        // We will begin rotation, only after we have passed
        // 60% of the way of reaching the threshold.
        if scrollOffset < self.threshold * 0.60 {
            return .degrees(0)
        } else {
            // Calculate rotation, based on the amount of scroll offset
            let h = Double(self.threshold)
            let d = Double(scrollOffset)
            let v = max(min(d - (h * 0.6), h * 0.4), 0)
            return .degrees(180 * v / (h * 0.4))
        }
    }
    
    struct SymbolView: View {
        var height: CGFloat
        var loading: Bool
        var frozen: Bool
        var rotation: Angle
        
        
        var body: some View {
            Group {
                if self.loading { // If loading, show the activity control
                    VStack {
                        Spacer()
                        ActivityRep()
                        Spacer()
                    }.frame(height: height).fixedSize()
                        .offset(y: -height + (self.loading && self.frozen ? height : 0.0))
                } else {
                    Image(systemName: "arrow.down") // If not loading, show the arrow
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: height * 0.25, height: height * 0.25).fixedSize()
                        .padding(height * 0.375)
                        .rotationEffect(rotation)
                        .offset(y: -height + (loading && frozen ? +height : 0.0))
                }
            }
        }
    }
    
    struct MovingView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .movingView, bounds: proxy.frame(in: .global))])
            }.frame(height: 0)
        }
    }
    
    struct FixedView: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .fixedView, bounds: proxy.frame(in: .global))])
            }
        }
    }
}

struct RefreshableKeyTypes {
    enum ViewType: Int {
        case movingView
        case fixedView
    }

    struct PrefData: Equatable {
        let vType: ViewType
        let bounds: CGRect
    }

    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []

        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            value.append(contentsOf: nextValue())
        }

        typealias Value = [PrefData]
    }
}

struct ActivityRep: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityRep>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView()
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityRep>) {
        uiView.startAnimating()
    }
}
