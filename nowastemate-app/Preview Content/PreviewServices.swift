//
//  PreviewServices.swift
//  nowastemate-app
//
//  Created by Zackary Overend on 9/16/26.
//

//Preview-only services returning fixed sample data so previews never reach the backend. https://developer.apple.com/videos/play/wwdc2020/10149/
#if DEBUG
import Foundation
import FirebaseAuth

struct PreviewRecipeService: RecipeServiceProtocol {

    func getAllRecipes(user: User, completionHandler: @escaping (Result<[Recipe], Error>) -> Void) {
        completionHandler(.success(Recipe.previewSamples))
    }

    func generateRecipe(user: User, productIds: [String], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        completionHandler(.success(()))
    }

    func deleteRecipe(user: User, recipeId: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        completionHandler(.success(()))
    }
}

struct PreviewFamilyService: FamilyServiceProtocol {
    
    func postFamily(user: User, title: String, completionHandler: @escaping (Result<String, Error>) -> Void) {}

    func joinFamily(user: User, code: String, completionHandler: @escaping (Result<String, Error>) -> Void) {}

    func getFamilyId(user: User, completionHandler: @escaping (Result<[String], Error>) -> Void) {
        completionHandler(.success(["preview-family"]))
    }

    func getFamilyMembers(user: User, completionHandler: @escaping (Result<[FamilyMember], Error>) -> Void) {
        completionHandler(.success([FamilyMember(member: "id", email: "email")]))
    }
    
    func getFamily(user: User, completionHandler: @escaping (Result<Family, Error>) -> Void) {
        completionHandler(.success(Family(title: "Family Preview", ownerId: "Placeholder")))
    }
    
    func updateFamilyName(user: User, title: String, completionHandler: @escaping (Result<String, Error>) -> Void) {}
    
    func updateOwner(user: User, member: FamilyMember, completionHandler: @escaping (Result<String, Error>) -> Void) {}
    
    func deleteFamilyMembership(user: User, member: FamilyMember, completionHandler: @escaping (Result<String, Error>) -> Void) {}
    
    func deleteOwnMembership(user: User, member: FamilyMember, completionHandler: @escaping (Result<String, Error>) -> Void) {}

    func deleteFamily(user: User, completionHandler: @escaping (Result<Void, Error>) -> Void) {}

}

struct PreviewProductService: ProductServiceProtocol {

    func getProducts(user: User, completionHandler: @escaping (Result<[Product], Error>) -> Void) {
        completionHandler(.success(Product.previewSamples))
    }

    func getFamilyProducts(user: User, completionHandler: @escaping (Result<[Product], Error>) -> Void) {
        completionHandler(.success(Product.previewSamples))
    }
    
    func addProduct(user: User, product: Product, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        completionHandler(.success(()))
    }

    func deleteProduct(user: User, product: Product, completionHandler: @escaping (Result<[Product], Error>) -> Void) {
        completionHandler(.success(Product.previewSamples))
    }

    func editProduct(user: User, product: Product, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        completionHandler(.success(()))
    }
    
    func getBarcodeDetails(user: User, barcode: String, completionHandler: @escaping (Result<Product, Error>) -> Void) {
        completionHandler(.success(
            Product(id: "preview-scanned", name: "Nutella", quantity: 1,
                    createdAt: "2026-09-15T00:00:00Z", category: .other)
        ))
    }
    func markProductOutcome(user: User, product: Product, outcome: ProductOutcome, wasteReason: WasteReason?, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        completionHandler(.success(()))
    }
    func getWasteDiagnostic(user: User, product: Product, completionHandler: @escaping (Result<WasteReason, Error>) -> Void) {}

}

struct PreviewAnalyticsService: AnalyticsServiceProtocol {
    func getUserWasteOvertime(user: User, period: TrendPeriod, periods: Int, completionHandler: @escaping (Result<WasteTrend, Error>) -> Void) {
        completionHandler(.success(.previewSample(period: period, periods: periods)))
    }
    func getProductUsageOverview(user: User, days: Int?, completionHandler: @escaping (Result<ProductUsage, Error>) -> Void) {
        completionHandler(.success(ProductUsage(days: days, consumedCount: 14, usedInRecipeCount: 5, wastedCount: 6, byReason: ["expired": 3, "forgot": 2])))
    }
    func getCategoryWaste(user: User, familyId: String?, completionHandler: @escaping (Result<CategoryWaste, any Error>) -> Void) {
        completionHandler(.success(CategoryWaste(produce: 10, dairy: 5, canned: 2, beverage: 3, other: 25 )))
    }
}

extension WasteTrend {
    // Fixed counts with one empty group, so previews show gaps and stacked reasons
    static func previewSample(period: TrendPeriod, periods: Int = 6) -> WasteTrend {
        let calendar = Calendar.current
        let unit: Calendar.Component = period == .week ? .weekOfYear : .month
        let current = calendar.dateInterval(of: unit, for: .now)?.start ?? .now
        let wasted = [3, 1, 4, 0, 2, 5]
        
        let buckets = (0..<periods).reversed().map { n -> WasteTrendInformation in
            let count = wasted[n % wasted.count]
            return WasteTrendInformation(
                periodStart: calendar.date(byAdding: unit, value: -n, to: current) ?? current,
                wastedCount: count,
                consumedCount: count + 2,
                byReason: count == 0 ? [:] : ["expired": count - 1, "boughtTooMuch": 1]
            )
        }
        return WasteTrend(period: period, buckets: buckets)
    }
}

extension Recipe {

    static var previewSamples: [Recipe] {
        let categories: [RecipeCategory?] = [
            .soup, .salad, .pasta, .handheld, .breakfast,
            .dessert, .drink, .platedMain, .general, nil
        ]
        return categories.map { preview(category: $0) }
    }

    static func preview(category: RecipeCategory?) -> Recipe {
        Recipe(
            id: category?.rawValue ?? "uncategorised",
            recipeName: (category?.rawValue ?? "uncategorised").capitalized + " Sample Recipe",
            description: "Sample recipe used for preview only.",
            prepTime: 10,
            cookTime: 25,
            servings: 2,
            difficulty: "easy",
            ingredientsUsed: 4,
            ingredients: [],
            instructions: [],
            createdAt: "2026-09-15T00:00:00Z",
            category: category
        )
    }

    // The samples above have no ingredients or steps, so RecipeDetailView gets a full one
    static var detailPreviewSample: Recipe {
        Recipe(
            id: "detail-preview",
            recipeName: "Tomato Parmesan Pasta",
            description: "A quick weeknight pasta that uses up ripe tomatoes before they turn.",
            prepTime: 10,
            cookTime: 20,
            servings: 2,
            difficulty: "easy",
            ingredientsUsed: 3,
            ingredients: [
                Ingredient(name: "Pasta", quantity: 200, unit: "g"),
                Ingredient(name: "Tomatoes", quantity: 4, unit: ""),
                Ingredient(name: "Parmesan", quantity: 30, unit: "g"),
                Ingredient(name: "Garlic", quantity: 2, unit: "cloves"),
                Ingredient(name: "Olive oil", quantity: 2, unit: "tbsp"),
                Ingredient(name: "Fresh basil", quantity: 0.5, unit: "cup"),
            ],
            instructions: [
                "Bring a large pot of salted water to a boil and cook the pasta until al dente. Save half a cup of the pasta water before draining.",
                "While the pasta cooks, dice the tomatoes and thinly slice the garlic.",
                "Heat the olive oil in a large pan over medium heat. Add the garlic and cook for 1 minute until fragrant.",
                "Add the tomatoes and a pinch of salt. Cook for 5 to 7 minutes until they break down into a sauce.",
                "Toss the drained pasta into the pan with a splash of pasta water. Stir in the parmesan until glossy.",
                "Tear the basil over the top and serve right away.",
            ],
            createdAt: "2026-10-12T00:00:00Z",
            category: .pasta
        )
    }
}

// Copied from the backend's Product Type list, with names that are close to each other (pea/pear, tomato/cherry tomato)
extension ProductType {

    static var previewSamples: [ProductType] {
        [
            ProductType(key: "tomato", name: "tomato", synonyms: ["tomatoes"], parents: ["fruit-vegetable"], category: .produce),
            ProductType(key: "cherry-tomato", name: "cherry tomato", synonyms: ["cherry tomatoes"], parents: ["tomato"], category: .produce),
            ProductType(key: "spring-onion", name: "spring onion", synonyms: ["green onion", "scallions", "spring onions", "green onions"], parents: ["onion"], category: .produce),
            ProductType(key: "onion", name: "onion", synonyms: ["onions"], parents: ["onion-family-vegetable", "root-vegetable"], category: .produce),
            ProductType(key: "egg", name: "egg", synonyms: ["eggs"], parents: [], category: .other),
            ProductType(key: "chicken", name: "chicken", synonyms: ["chickens"], parents: ["poultry"], category: .meat),
            ProductType(key: "chicken-breast", name: "chicken breast", synonyms: ["chicken breast meat"], parents: ["chicken-meat"], category: .meat),
            ProductType(key: "milk", name: "milk", synonyms: ["milk ingredients"], parents: ["dairy"], category: .dairy),
            ProductType(key: "rice", name: "rice", synonyms: [], parents: [], category: .grains),
            ProductType(key: "pea", name: "pea", synonyms: ["peas"], parents: ["legume", "pod-and-seed-vegetable"], category: .produce),
            ProductType(key: "pear", name: "pear", synonyms: ["pears"], parents: ["fruit"], category: .produce),
        ]
    }
}

extension Product {

    static var previewSamples: [Product] {
        [
            Product(id: "preview-1", name: "Tomatoes", quantity: 4,
                    createdAt: "2026-09-15T00:00:00Z", dateExpiration: previewExpiry(inDays: 1), category: .produce),
            Product(id: "preview-2", name: "Pasta", quantity: 1,
                    createdAt: "2026-09-15T00:00:00Z", category: .grains),
            Product(id: "preview-3", name: "Parmesan", quantity: 1,
                    createdAt: "2026-09-15T00:00:00Z", dateExpiration: previewExpiry(inDays: 3), category: .dairy),
            Product(id: "preview-4", name: "Milk", quantity: 1,
                    createdAt: "2026-09-15T00:00:00Z", dateExpiration: previewExpiry(inDays: -1), category: .dairy),
            Product(id: "preview-4", name: "Milk", quantity: 1,
                    createdAt: "2026-09-15T00:00:00Z", dateExpiration: previewExpiry(inDays: -1), category: .dairy),
            Product(id: "preview-4", name: "Milk", quantity: 1,
                    createdAt: "2026-09-15T00:00:00Z", dateExpiration: previewExpiry(inDays: -1), category: .dairy),
            
        ]
    }

    // Relative to today so the expiry labels and Home's Expiring Soon card always have something to show
    private static func previewExpiry(inDays days: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
        return ISO8601DateFormatter().string(from: date)
    }
}
#endif
