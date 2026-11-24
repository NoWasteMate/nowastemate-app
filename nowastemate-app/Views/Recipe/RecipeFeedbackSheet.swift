//
//  RecipeFeedbackSheet.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 2026-11-23.
//

import SwiftUI
import FirebaseAuth

struct RecipeFeedbackSheet: View {
    let recipe: Recipe

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var familyVM: FamilyViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selected: Set<String> = []
    @State private var isScrolled = false
    @State private var showOtherProducts = false

    // nil means not answered
    @State private var makeAgain: Bool?
    @State private var leftovers: Leftovers?

    // How far the content scrolls before the small title shows (roughly the height of the large title)
    private let titleScrollDistance: CGFloat = 56

    private var hasFamily: Bool { familyVM.familyId != nil }

    // Family list once it has loaded, otherwise just the user's own. Used products no longer show up in either
    private var activeProducts: [Product] {
        let products = productVM.hasLoadedFamilyProducts ? productVM.familyProducts : productVM.products
        return products.filter { $0.outcome == nil || $0.outcome == .active }
    }

    private var recipeProducts: [Product] {
        activeProducts.filter { productVM.isUsed($0, in: recipe.ingredients) }
    }

    private var otherProducts: [Product] {
        activeProducts.filter { !productVM.isUsed($0, in: recipe.ingredients) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                largeTitle
                // Questions first so they can be answered without scrolling past the products
                makeAgainSection
                leftoversSection
                productSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        // Tracks when the large title scrolls away, same as GenerateRecipeSheet
        // https://stackoverflow.com/a/79409972
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top > titleScrollDistance
        } action: { _, scrolled in
            withAnimation(.snappy) {
                isScrolled = scrolled
            }
        }
        .safeAreaBar(edge: .top) { header }
        .safeAreaBar(edge: .bottom) {
            VStack(spacing: 8) {
                if let errorMessage = recipeVM.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 24)
                }
                saveButton
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .all)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            recipeVM.errorMessage = nil
            selected = ownRecipeIDs
            // Reloads every time so a product another member removed doesn't 404 the save
            // Only with a family since the backend 404s without one, which would put an error on the product list
            if hasFamily, let user = authVM.user {
                productVM.loadFamilyProducts(for: user)
            }
        }
    }

    // Small title fades in once the large title scrolls away, like system large titles
    private var header: some View {
        ZStack {
            Text("How did it go?")
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
            Image(systemName: "fork.knife")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color("RecipeListGradientPrimary"))
            Text("How did it go?")
                .font(.title.bold())
        }
        .frame(maxWidth: .infinity)
        .opacity(isScrolled ? 0 : 1)
    }

    // Recipe products stay in the list when unticked so you can still see they were in the recipe
    private var productSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("PRODUCTS USED")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                Spacer()
                if !recipeProducts.isEmpty {
                    Button(allRecipeSelected ? "Deselect All" : "Select All") {
                        if allRecipeSelected {
                            selected.subtract(recipeIDs)
                        } else {
                            selected.formUnion(recipeIDs)
                        }
                    }
                    .font(.subheadline)
                    .tint(Color("RecipeListGradientPrimary"))
                }
            }
            .padding(.bottom, 8)

            if recipeProducts.isEmpty {
                Text("Nothing you have matches this recipe")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.fill.quaternary, in: .rect(cornerRadius: 16))
            } else {
                FeedbackProductList(products: recipeProducts, selected: $selected, showsOwner: hasFamily)
            }

            if !otherProducts.isEmpty {
                Button {
                    withAnimation(.snappy) {
                        showOtherProducts.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(showOtherProducts ? "Hide other products" : "Show other products (\(otherProducts.count))")
                        Image(systemName: showOtherProducts ? "chevron.up" : "chevron.down")
                            .font(.footnote.weight(.semibold))
                    }
                }
                .font(.subheadline)
                .tint(Color("RecipeListGradientPrimary"))
                .padding(.top, 12)

                if showOtherProducts {
                    FeedbackProductList(products: otherProducts, selected: $selected, showsOwner: hasFamily)
                        .padding(.top, 8)
                        .transition(.opacity)
                }
            }
        }
    }

    private var makeAgainSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Would you make it again?")
                .font(.headline)
            Picker("Would you make it again?", selection: $makeAgain) {
                Text("Yes").tag(Optional(true))
                Text("No").tag(Optional(false))
            }
            .pickerStyle(.segmented)
        }
    }

    private var leftoversSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Was there food left over?")
                .font(.headline)
            Picker("Was there food left over?", selection: $leftovers) {
                Text("None").tag(Optional(Leftovers.noneLeft))
                Text("A little").tag(Optional(Leftovers.little))
                Text("Lots").tag(Optional(Leftovers.lots))
            }
            .pickerStyle(.segmented)
        }
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Label("Save", systemImage: "checkmark")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .tint(Color("RecipeListGradientPrimary"))
        .disabled(recipeVM.isSavingFeedback)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private func save() {
        guard let user = authVM.user else { return }
        let request = AddRecipeFeedbackRequest(
            productIds: Array(selected),
            makeAgain: makeAgain,
            leftovers: leftovers
        )
        recipeVM.addRecipeFeedback(for: user, recipe: recipe, request: request) {
            productVM.loadProducts(for: user)
            if productVM.hasLoadedFamilyProducts {
                productVM.loadFamilyProducts(for: user)
            }
            dismiss()
        }
    }

    // Only your own products start ticked so one recipe doesn't use up everyone's eggs.
    // Your products are in both lists with the same ids, so the family list loading later doesn't change this
    private var ownRecipeIDs: Set<String> {
        let ownProducts = recipeProducts.filter { $0.ownerId == nil || $0.ownerId == authVM.user?.uid }
        return Set(ownProducts.compactMap(\.id))
    }

    private var recipeIDs: Set<String> {
        Set(recipeProducts.compactMap(\.id))
    }

    private var allRecipeSelected: Bool {
        recipeIDs.isSubset(of: selected)
    }
}

private struct FeedbackProductList: View {
    var products: [Product]
    @Binding var selected: Set<String>
    var showsOwner: Bool

    // Same grouping as GenerateRecipeSheet and ProductListView
    // https://danielsaidi.com/blog/2023/04/01/group-and-sort-swift-collections-like-a-pro
    private var groupedProducts: [ProductCategory: [Product]] {
        Dictionary(grouping: products, by: { $0.category ?? .other })
    }

    private var sortedCategories: [ProductCategory] {
        ProductCategory.allCases.filter { groupedProducts[$0] != nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(sortedCategories, id: \.self) { category in
                if let items = groupedProducts[category] {
                    CategoryHeader(
                        title: category.rawValue,
                        selectedCount: items.filter(isSelected).count,
                        totalCount: items.count
                    )
                    .padding(.top, category == sortedCategories.first ? 10 : 20)

                    ForEach(items) { product in
                        Divider()
                            .padding(.leading, 36)
                        FeedbackProductRow(
                            product: product,
                            isSelected: isSelected(product),
                            showsOwner: showsOwner
                        ) {
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

private struct FeedbackProductRow: View {
    var product: Product
    var isSelected: Bool
    var showsOwner: Bool
    var onTap: () -> Void

    @EnvironmentObject var authVM: AuthViewModel

    // Same labels as ProductRowView in the family list
    private var ownerLabel: String? {
        guard showsOwner, let ownerId = product.ownerId else { return nil }
        return ownerId == authVM.user?.uid ? "You" : (product.ownerName ?? "Member")
    }

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
                    if let ownerLabel {
                        OwnerBadge(name: ownerLabel)
                    }
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
    NavigationStack {
        RecipeDetailView(recipe: .detailPreviewSample)
    }
    .sheet(isPresented: .constant(true)) { RecipeFeedbackSheet(recipe: .detailPreviewSample) }
}
#endif
