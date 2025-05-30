import SwiftUI

public struct GlassTabView: View {
    public init(selection: Binding<String>? = nil, @TabItemsBuilder content: () -> [TabItem]) {
        self.selectionBinding = selection ?? .constant("")
        let items = content()
        precondition(items.count <= 5, "Maximum 5 tabs allowed")
        self.tabItems = items
        self._selected = State(initialValue: items.first!.id)
        self._selectedInBar = State(initialValue: items.first!.id)
    }
    var selectionBinding: Binding<String>
    @State var tabItems: [TabItem]
    @State var selected: String
    @Namespace private var animation
    @State var yOffset: CGFloat = 0
    @State var lastYOffset: CGFloat = 0
    @State var collapsed = false
    @State var selectedInBar: String {
        didSet {
            DispatchQueue.main.async {
                selectionBinding.wrappedValue = selectedInBar
            }
        }
    }
    public var body: some View {
        ZStack {
            TabView(selection: $selected) {
                ForEach(tabItems) { tabItem in
                    tabItem.content
                        .tag(tabItem.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            HStack {
                ForEach(tabItems) { tabItem in
                    VStack {
                        tabItem.icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text(tabItem.title)
                            .font(.caption)
                            .bold()
                    }
                    .foregroundStyle(selectedInBar == tabItem.id ? Color.accentColor : Color.gray)
                    .padding()
                    .frame(width: 75, height: 60)
                    .background {
                        if selectedInBar == tabItem.id {
                            Capsule()
                                .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                                .matchedGeometryEffect(id: "TabItem", in: animation)
                                .shadow(color: Color(uiColor: .gray).opacity(0.5), radius: 5)
                        }
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.bouncy) {
                            selected = tabItem.id
                        }
                    }
                }
            }
            .padding(5)
            .background(
                Capsule()
                    .foregroundStyle(.ultraThinMaterial)
                    .shadow(color: Color(uiColor: .gray).opacity(0.35), radius: 15)
            )
            .scaleEffect(tabItems.count <= 5 ? 0.90 : 1)
            .onLongPressGesture(minimumDuration: 0.25) {
                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                impactHeavy.impactOccurred()
                collapsed = true
            }
            .gesture(
                DragGesture(minimumDistance: 2.5)
                    .onChanged { gesture in
                        if gesture.translation.height - lastYOffset >= 0 {
                            yOffset += 0.25
                            lastYOffset = gesture.translation.height
                        }
                    }
                    .onEnded { _ in
                        if yOffset >= 1 {
                        } else {
                            withAnimation(.bouncy) {
                                yOffset = 0
                                lastYOffset = 0
                            }
                        }
                    }
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: yOffset)
            
            Button(action: {
                withAnimation(.bouncy) {
                    collapsed = false
                }
            }) {
                Image(systemName: "chevron.up")
                    .font(.body.bold())
                    .foregroundStyle(.gray)
                    .padding()
                    .background(
                        Color(.gray).opacity(0.5)
                            .blur(radius: 25)
                            .clipShape(.capsule)
                            .blur(radius: 5)
                    )
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: 150 + -yOffset)
        }
        .onChange(of: collapsed) { newValue in
            if !newValue {
                withAnimation(.bouncy) {
                    yOffset = 0
                    lastYOffset = 0
                }
            } else {
                withAnimation(.bouncy) {
                    yOffset = 150
                    lastYOffset = 0
                }
            }
        }
        .onChange(of: selected) { _ in
            withAnimation(.bouncy) {
                selectedInBar = selected
            }
            let impactSoft = UIImpactFeedbackGenerator(style: .rigid)
            impactSoft.impactOccurred()
        }
        .onChange(of: selectionBinding.wrappedValue) { newValue in
            selected = newValue
        }
    }
}

public struct TabItem: Identifiable {
    public init(id: String = UUID().uuidString, title: String, image: Image, @ViewBuilder content: () -> some View) {
        self.id = id
        self.content = AnyView(content())
        self.title = title
        self.icon = image
    }
    public init(id: String = UUID().uuidString, title: String, systemImage: String, content: AnyView) {
        self.id = id
        self.content = content
        self.title = title
        self.icon = Image(systemName: systemImage)
    }
    public var id: String
    public var content: AnyView
    public var title: String
    public var icon: Image
}

@resultBuilder
public struct TabItemsBuilder {
    public static func buildBlock(_ t1: TabItem) -> [TabItem] {
        [t1]
    }
    public static func buildBlock(_ t1: TabItem, _ t2: TabItem) -> [TabItem] {
        [t1, t2]
    }
    public static func buildBlock(_ t1: TabItem, _ t2: TabItem, _ t3: TabItem) -> [TabItem] {
        [t1, t2, t3]
    }
    public static func buildBlock(_ t1: TabItem, _ t2: TabItem, _ t3: TabItem, _ t4: TabItem) -> [TabItem] {
        [t1, t2, t3, t4]
    }
    public static func buildBlock(_ t1: TabItem, _ t2: TabItem, _ t3: TabItem, _ t4: TabItem, _ t5: TabItem) -> [TabItem] {
        [t1, t2, t3, t4, t5]
    }
}
