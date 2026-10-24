//
//  RecipeDetailView.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 15/11/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirm = false

    // photo moves at 80% of the scroll speed
    private let imageParallaxAmount: CGFloat = 0.2

    var body: some View {
    
        ZStack {
            backgroundGradient.ignoresSafeArea()
            ScrollView(){
                VStack(spacing: 0) {
                    // Older recipes and failed image calls have no imageUrl
                    if let imageUrl = recipe.imageUrl {
                        // Same 3:4 as the generated image so the header doesn't jump when it loads
                        // https://sarunw.com/posts/how-to-resize-swiftui-image-and-keep-aspect-ratio/
                        Color.white.opacity(0.15)
                            .aspectRatio(3 / 4, contentMode: .fit)
                            .overlay {
                                AsyncImage(url: imageUrl) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.clear
                                }
                            }
                            .clipped()
                            // Photo scrolls slower than the recipe for a parallax header
                            // Based on their rotation example but uses scroll offsets instead
                            // https://www.hackingwithswift.com/books/ios-swiftui/scrollview-effects-using-visualeffect-and-scrolltargetbehavior
                            .visualEffect { content, geometry in
                                // Global minY works as the scroll offset since the header starts at the top of the screen
                                // min() ignores pulling down past the top
                                let scrollOffset = min(geometry.frame(in: .global).minY, 0)
                                return content.offset(y: -scrollOffset * imageParallaxAmount)
                            }
                    }

                    // Padding here instead of on the ScrollView so the photo goes edge to edge
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.recipeName)
                                .font(.largeTitle)
                            Text(recipe.description)
                                .font(.title3)
                        }

                        HStack {
                            StatView(systemImage: "timer", value: "\(recipe.prepTime) min", label: "Prep")
                            StatView(systemImage: "flame", value: "\(recipe.cookTime) min", label: "Cook")
                            StatView(systemImage: "person.2", value: "\(recipe.servings)", label: "Serves")
                            StatView(systemImage: "chart.bar", value: recipe.difficulty.capitalized, label: "Level")
                        }
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .glassEffect(.clear.interactive(false), in: .rect(cornerRadius: 16))

                        VStack(alignment: .leading, spacing: 10) {
                            // https://www.hackingwithswift.com/forums/swiftui/accessing-the-index-in-foreach/1334
                            // Accessing indicies in for each (there is no id for ingredients)
                            ForEach(recipe.ingredients.indices, id: \.self) { index in
                                let ingredient = recipe.ingredients[index]
                                let availability = productVM.availability(for: ingredient)
                                HStack(spacing: 8) {
                                    Image(systemName: icon(for: availability))
                                        .foregroundStyle(iconColour(for: availability))
                                    // Language model sends plain lowercase names like "chicken breast"
                                    Text(ingredient.name.capitalized)
                                    Spacer()
                                    // formatted() drops the trailing .0 so 200.0 shows as 200
                                    // Skips the space when there's no unit, otherwise "4 " sits out of line with the rest
                                    Text(ingredient.unit.isEmpty ? ingredient.quantity.formatted() : "\(ingredient.quantity.formatted()) \(ingredient.unit)")
                                        .opacity(0.8)
                                }
                        
                            
                            }

                        }
                        // Same inset as the step cards' padding so the icons line up with the step numbers
                        .padding(.horizontal)
                        // Extra room before the steps so the plain list doesn't run into the first card
                        .padding(.bottom, 12)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(recipe.instructions.indices, id: \.self) { index in
                                StepCardView(number: index + 1, text: recipe.instructions[index])
                            }
                        }
                    }
                    .padding()
                    // Covers the photo as the parallax pushes it down behind the recipe
                    .background {
                        if recipe.imageUrl != nil {
                            backgroundGradient
                        }
                    }
                }.foregroundStyle(.white)
            }
            .scrollIndicators(.hidden)
            // Photo goes under the status bar and navigation buttons
            .ignoresSafeArea(.container, edges: recipe.imageUrl == nil ? [] : .top)

        }
        // Stops the screen locking while someone is cooking from the recipe
        // https://developer.apple.com/forums/thread/659905
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        // The forum answer never shows turning it back to false but its necessary or the entire app will remain isIdleTimerDisabled
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Delete Recipe", systemImage: "trash", role: .destructive) {
                    showDeleteConfirm = true
                }
                // Attached to the button so iOS 26 shows it as a popover from the trash icon
                // https://useyourloaf.com/blog/swiftui-confirmation-dialogs/
                .confirmationDialog("Delete this recipe?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        if let user = authVM.user {
                            recipeVM.deleteRecipe(for: user, recipe: recipe)
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color("RecipeListGradientPrimary"), Color("RecipeListGradientSecondary")],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func icon(for availability: IngredientAvailability) -> String {
        switch availability {
        case .owned: return "checkmark.circle.fill"
        case .missing: return "xmark.circle"
        case .unknown: return "circle.dotted"
        }
    }

    private func iconColour(for availability: IngredientAvailability) -> Color {
        switch availability {
        case .owned: return .green
        case .missing: return .white.opacity(0.6)
        case .unknown: return .white.opacity(0.35)
        }
    }
}

private struct StatView: View {
    var systemImage: String
    var value: String
    var label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.title3)
            Text(value)
                .font(.subheadline.bold())
            Text(label)
                .font(.caption)
                .opacity(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StepCardView: View {
    var number: Int
    var text: String

    // Ticked off while cooking
    @State private var isDone = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isDone ? "checkmark.circle.fill" : "\(number).circle")
                .font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text("Step \(number)")
                    .font(.caption.bold())
                    .textCase(.uppercase)
                    .opacity(0.7)
                Text(text)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        // Done steps fade back so the next one stands out
        .opacity(isDone ? 0.4 : 1)
        .glassEffect(.clear, in: .rect(cornerRadius: 16))
        .onTapGesture {
            isDone.toggle()
        }
    }
}

#if DEBUG
#Preview(traits: .appEnvironment) {
    // NavigationStack so the toolbar shows up
    NavigationStack {
        RecipeDetailView(recipe: .detailPreviewSample)
    }
}
#endif
