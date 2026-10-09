//
//  GenerateRecipeSheet.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 22/9/26.
//

import SwiftUI

// Sheet opened from the generate button on the recipe list.
// Medium size: quick product picker, Large size: grouped by category & generation options
struct GenerateRecipeSheet: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selected: Set<String> = []
    @State private var isScrolled = false
    @State private var detent: PresentationDetent = .medium
    @State private var showPreferences = false

    @State private var mealType = "Any"
    @State private var difficulty = "Any"
    @State private var maxCookTime: Double = 45
    @State private var servings = 2
    @State private var prioritiseExpiring = true

    private let mealTypes = ["Any", "Breakfast", "Soup", "Salad", "Pasta", "Handheld", "Plated Main", "Dessert", "Drink"]
    private let difficulties = ["Any", "Easy", "Medium", "Hard"]

    // How far the content scrolls before the small title shows (roughly the height of the large title)
    private let titleScrollDistance: CGFloat = 56

    // Same grouping as ProductListView references:
    // https://danielsaidi.com/blog/2023/04/01/group-and-sort-swift-collections-like-a-pro
    private var groupedProducts: [ProductCategory: [Product]] {
        Dictionary(grouping: productVM.products, by: { $0.category ?? .other })
    }

    private var sortedCategories: [ProductCategory] {
        ProductCategory.allCases.filter { groupedProducts[$0] != nil }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                largeTitle
                productSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .animation(.snappy, value: detent)
        }
        .scrollIndicators(.hidden)
        // Tracks when the large title scrolls away. The top bar is a fixed height so this can't shift the scroll and retrigger itself
        // https://developer.apple.com/documentation/swiftui/view/onscrollgeometrychange(for:of:action:)
        // Adding contentInsets.top gives the real zero point: https://www.donnywals.com/building-a-stretchy-header-view-with-swiftui-on-ios-18/
        // https://stackoverflow.com/a/79409972
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top > titleScrollDistance
        } action: { _, scrolled in
            withAnimation(.snappy) {
                isScrolled = scrolled }
        }
        // Tap outside to close the options panel
        .overlay {
            if showPreferences {
                Color.clear
                    .contentShape(.rect)
                    .onTapGesture { setPreferences(open: false) }
            }
        }
        .safeAreaBar(edge: .top) { header }
        .safeAreaBar(edge: .bottom) {
            // Uses a small offset instead of .move(edge: .bottom), which slid past the Generate button on a fast drag
            VStack(spacing: 12) {
                if detent == .large {
                    generationOptions
                        .transition(.opacity.combined(with: .offset(y: 12)))
                }
                generateButton
                    .zIndex(1)
            }
            .animation(.smooth, value: detent)
        }
        .scrollEdgeEffectStyle(.soft, for: .all)
        .presentationDetents([.medium, .large], selection: $detent)
        .presentationDragIndicator(.visible)
        .onAppear { selected = allIDs }
        // Close the options panel when the sheet is dragged back to medium
        .onChange(of: detent) { _, newDetent in
            if newDetent != .large { showPreferences = false }
        }
    }

    // Small title fades in once the large title scrolls away, like system large titles
    private var header: some View {
        ZStack {
            Text("Generate a Recipe")
                .font(.headline)
                .opacity(isScrolled ? 1 : 0)

            Button("Close", systemImage: "xmark") {
                dismiss()
            }
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var largeTitle: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color("RecipeListGradientPrimary"))
            Text("Generate a Recipe")
                .font(.title.bold())
        }
        .frame(maxWidth: .infinity)
        .opacity(isScrolled ? 0 : 1)
    }
    
    
    // Flat list at medium, grouped by category at large
    private var productSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("PRODUCTS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                Spacer()
                Button(allSelected ? "Deselect All" : "Select All") {
                    selected = allSelected ? [] : allIDs
                }
                .font(.subheadline)
                .tint(Color("RecipeListGradientPrimary"))
            }
            .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(sortedCategories, id: \.self) { category in
                    if let items = groupedProducts[category] {
                        if showCategories {
                            CategoryHeader(
                                title: category.rawValue,
                                selectedCount: items.filter(isSelected).count,
                                totalCount: items.count
                            )
                            .padding(.top, category == sortedCategories.first ? 10 : 20)
                            // Delay on insert so the rows move first, then the header appears
                            // https://developer.apple.com/documentation/swiftui/anytransition/animation(_:)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .offset(y: -6)).animation(.snappy.delay(0.15)),
                                removal: .opacity.animation(.snappy(duration: 0.15))
                            ))
                        }

                        ForEach(items) { product in
                            // Every row keeps its divider in both layouts so only the headers animate. The first one is hidden in the flat list since nothing sits above it
                            Divider()
                                .padding(.leading, 36)
                                .opacity(product.id == firstProductID && !showCategories ? 0 : 1)
                            SelectableProductRow(product: product, isSelected: isSelected(product)) {
                                toggle(product)
                            }
                        }
                    }
                }
            }
            // Light background behind the list, like an inset grouped list
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(.fill.quaternary, in: .rect(cornerRadius: 16))
        }
    }

    
    // One glass shape that resizes, contents swap inside it.
    // Tried glassEffectID with two views first but the panel contents popped in at full size
    // https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)
    private var generationOptions: some View {
        // ZStack so during the swap the glass sizes to the bigger view, not both stacked
        ZStack(alignment: .bottom) {
            if showPreferences {
                optionsPanel
                    .transition(optionsContentTransition)
            } else {
                optionsSummary
                    .transition(optionsContentTransition)
            }
        }
        .clipShape(.rect(cornerRadius: 24))
        // Regular not .interactive(), toggling interactive mid-animation made the transparency jump
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
        .padding(.horizontal, 24)
    }

    // Old contents fade out fast, new contents fade in after the glass has resized
    private var optionsContentTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.animation(.smooth(duration: 0.25).delay(0.2)),
            removal: .opacity.animation(.smooth(duration: 0.1))
        )
    }

    // Collapsed pill
    private var optionsSummary: some View {
        Button {
            setPreferences(open: true)
        } label: {
            HStack(spacing: 8) {
                Label("Generation options", systemImage: "slider.horizontal.3")
                // Chevron up since it expands in place, a right chevron would suggest a new screen
                Image(systemName: "chevron.up")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color("RecipeListGradientPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    // Expanded panel. Checkmark is the iOS 26 Done button, styled like the close buttons on Maps cards
    private var optionsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(Color("RecipeListGradientPrimary"))
                Text("Generation options")
                Spacer()
                Button("Done", systemImage: "checkmark") { setPreferences(open: false) }
                    .labelStyle(.iconOnly)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("RecipeListGradientPrimary"))
                    .frame(width: 30, height: 30)
                    .background(.fill.tertiary, in: .circle)
                    .contentShape(.circle)
                    .buttonStyle(.plain)
            }
            .font(.headline)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Meal")
                    Spacer()
                    mealPicker
                }
                .padding(.vertical, 6)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty")
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 10)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Cook time")
                        Spacer()
                        Text("Up to \(Int(maxCookTime)) min")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $maxCookTime, in: 10...120, step: 5)
                        .tint(Color("RecipeListGradientPrimary"))
                }
                .padding(.vertical, 10)

                HStack {
                    Text("Servings")
                    Spacer()
                    Stepper("\(servings)", value: $servings, in: 1...8)
                        .fixedSize()
                }
                .padding(.vertical, 6)

                Toggle("Use expiring items first", isOn: $prioritiseExpiring)
                    .tint(Color("RecipeListGradientPrimary"))
                    .padding(.vertical, 10)
            }
        }
        .padding(20)
    }

    // Menu labels don't update until the menu finishes closing so the value lagged behind.
    // Drawing the value outside the menu and putting the menu behind it fixes it
    // https://developer.apple.com/documentation/swiftui/menu
    // https://developer.apple.com/documentation/swiftui/view/transaction(value:_:)
    private var mealPicker: some View {
        HStack(spacing: 4) {
            Text(mealType)
            Image(systemName: "chevron.up.chevron.down")
                .font(.footnote.weight(.semibold))
        }
        .foregroundStyle(Color("RecipeListGradientPrimary"))
        .transaction(value: mealType) { $0.animation = nil }
        .frame(width: 200, alignment: .trailing)
        .allowsHitTesting(false)
        .background {
            Menu {
                Picker("Meal", selection: $mealType) {
                    ForEach(mealTypes, id: \.self) { Text($0) }
                }
                .pickerStyle(.inline)
            } label: {
                Color.clear
                    .contentShape(.rect)
            }
        }
    }

    // TODO: send selected products + options once POST /generateRecipe takes a body (uses whole inventory at the moment)
    private var generateButton: some View {
        Button {
            if let user = authVM.user {
                recipeVM.generateRecipe(for: user)
            }
            dismiss()
        } label: {
            Label("Generate", systemImage: "sparkles")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .tint(Color("RecipeListGradientPrimary"))
        .disabled(selected.isEmpty)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    // Smooth instead of bouncy it made the glass overshoot its final size
    // https://developer.apple.com/documentation/swiftui/animation/smooth
    private func setPreferences(open: Bool) {
        withAnimation(.smooth(duration: 0.4)) {
            showPreferences = open
        }
    }

    private var showCategories: Bool { detent == .large }

    private var firstProductID: String? {
        sortedCategories.first.flatMap { groupedProducts[$0]?.first?.id }
    }

    private var allIDs: Set<String> {
        Set(productVM.products.compactMap(\.id))
    }

    private var allSelected: Bool {
        !productVM.products.isEmpty && selected.count == productVM.products.count
    }

    private func isSelected(_ product: Product) -> Bool {
        product.id.map(selected.contains) ?? false
    }

    private func toggle(_ product: Product) {
        guard let id = product.id else { return }
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }
}

private struct CategoryHeader: View {
    var title: String
    var selectedCount: Int
    var totalCount: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title.capitalized)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text("\(selectedCount) of \(totalCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.bottom, 6)
    }
}

private struct SelectableProductRow: View {
    var product: Product
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Fixed width so every row lines up with the divider inset (24 + 12 spacing)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? AnyShapeStyle(Color("RecipeListGradientPrimary")) : AnyShapeStyle(.tertiary))
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .foregroundStyle(.primary)
                    Text("Qty \(product.quantity)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    RecipeListView()
        .sheet(isPresented: .constant(true)) { GenerateRecipeSheet() }
}
#endif
