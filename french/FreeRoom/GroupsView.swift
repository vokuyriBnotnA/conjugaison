//
//  GroupsView.swift
//  french
//
//  Created by Anton on 01/07/2025.
//

import SwiftUI

struct VerticalSwipeView<Content: View>: View {
    let content: Content
    let pagesCount: Int
    @State private var currentPage = 0

    init(pagesCount: Int, @ViewBuilder content: () -> Content) {
        self.pagesCount = pagesCount
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            TabView(selection: $currentPage) {
                content
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .rotationEffect(.degrees(90))
            .frame(
                width: UIScreen.main.bounds.height,
                height: UIScreen.main.bounds.width
            )

            VStack(spacing: 12) {
                ForEach(0..<pagesCount, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.4))
                        .frame(width: index == currentPage ? 12 : 8,
                               height: index == currentPage ? 12 : 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.trailing, 20)
            .offset(x: 0, y: -UIScreen.main.bounds.width/2 + CGFloat(pagesCount) * 12)
            .zIndex(4)
        }
    }
}

struct VerticalPage<Content: View>: View {
    let content: Content
    let id: Int
    
    init(id: Int, @ViewBuilder content: () -> Content) {
        self.id = id
        self.content = content()
    }
    
    var body: some View {
        content
            .rotationEffect(.degrees(-90))
            .frame(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            )
            .tag(id)
    }
}
