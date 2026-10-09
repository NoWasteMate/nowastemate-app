//
//  PreviewEnvironment.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 9/16/26.
//

//Preview-only, kept out of release builds.
#if DEBUG
import SwiftUI
import FirebaseCore

// Shared preview environment that injects sample data services into every preview. https://www.donnywals.com/using-previewmodifier-to-build-a-previewing-environment/
struct AppPreviewEnvironment: PreviewModifier {
    
    //AppDelegate does not run in previews, so Firebase is configured here
    static func makeSharedContext() async throws {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    func body(content: Content, context: Void) -> some View {
        
        //Firebase has no public User initializer, so authVM.user stays nil in previews. Seed the products directly instead.
        let productVM = ProductViewModel(service: PreviewProductService())
        productVM.products = Product.previewSamples
        productVM.hasLoadedProducts = true

        let recipeVM = RecipeViewModel(service: PreviewRecipeService())
        recipeVM.recipes = Recipe.previewSamples

        
        //Marks the preview as signed in so RootView renders the tabs instead of LogInView.
        let authVM = AuthViewModel()
        authVM.isSignedIn = true

        return content
            .environmentObject(authVM)
            .environmentObject(FamilyViewModel(service: PreviewFamilyService()))
            .environmentObject(recipeVM)
            .environmentObject(productVM)
            .environmentObject(CameraViewModel())
    }
}

//Lets previews use #Preview(traits: .appEnvironment).
extension PreviewTrait where T == Preview.ViewTraits {
    static var appEnvironment: Self { .modifier(AppPreviewEnvironment()) }
}
#endif
