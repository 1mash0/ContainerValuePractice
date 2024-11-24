//
//  ContentView.swift
//  ContainerValues
//
//  Created by 今末 翔太 on 2024/10/21.
//

import SwiftUI

extension ContainerValues {
    @Entry var isFeatured: Bool = false
}
extension View {
    func featured(_ value: Bool = true) -> some View {
        containerValue(\.isFeatured, value)
    }
}

struct ContentView: View {
    private let colorItems: [Item] = [
        .init(color: .red, isFeatured: true),
        .init(color: .orange, isFeatured: false),
        .init(color: .cyan, isFeatured: false),
        .init(color: .yellow, isFeatured: true),
        .init(color: .green, isFeatured: true),
        .init(color: .gray, isFeatured: false),
    ]
    
    var body: some View {
        FeatureList {
            Section(header: Text("Header A"), footer: Text("Footer A")) {
                ForEach(colorItems) { item in
                    item.color
                        .featured(item.isFeatured)
                }
            }
            .scaledToFit()

            Section(header: Text("Header B"), footer: Text("Footer B")) {
                Color.green
                Color.yellow
            }
            .scaledToFit()
            .featured()

            Section(header: Text("Header C"), footer: Text("Footer C")) {
                Color.blue
                Color.purple
            }.scaledToFit()
        }
    }
}

struct Item: Identifiable {
    let color: Color
    let isFeatured: Bool
    
    init(color: Color, isFeatured: Bool) {
        self.color = color
        self.isFeatured = isFeatured
    }
    
    var id: UUID { UUID() }
}

struct FeatureList<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                Group(sections: content) { sections in
                    let featured = sections.filter(\.containerValues.isFeatured)
                    
                    if !sections.isEmpty {
                        ForEach(featured) { section in
                            section.header.padding([.top, .leading])
                            
                            FeatureCard {
                                section.content
                            }
                            
                            section.footer.padding(.leading)
                        }
                    }
                    
                    let notFeatured = sections.filter { !$0.containerValues.isFeatured }
                    
                    ForEach(notFeatured) { section in
                        section.header.padding([.top, .leading])
                        
                        FeatureCard {
                            section.content
                        }
                        
                        section.footer.padding(.leading)
                    }
                }
            }
        }
    }
}

struct FeatureCard<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(subviews: content) { subview in
                    subview
                        .containerRelativeFrame(.horizontal)
                        .frame(width: 80, height: 80)
                        .overlay(alignment: .center) {
                            if subview.containerValues.isFeatured {
                                Text("Feature")
                                    .bold()
                            }
                        }
                }
            }
        }
        .contentMargins(16)
    }
}

#Preview {
    ContentView()
}
