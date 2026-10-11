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

    func generateRecipe(user: User, completionHandler: @escaping (Result<Void, Error>) -> Void) {
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

    
}

struct PreviewProductService: ProductServiceProtocol {

    func getProducts(user: User, completionHandler: @escaping (Result<[Product], Error>) -> Void) {
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
        return WasteTrend(period: period, information: buckets)
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
}

extension Product {

    static var previewSamples: [Product] {
        [
            Product(id: "preview-1", name: "Tomatoes", quantity: 4,
                    createdAt: "2026-09-15T00:00:00Z", category: .produce),
            Product(id: "preview-2", name: "Pasta", quantity: 1,
                    createdAt: "2026-09-15T00:00:00Z", category: .grains),
            Product(id: "preview-3", name: "Parmesan", quantity: 1,
                    createdAt: "2026-09-15T00:00:00Z", category: .dairy)
        ]
    }
}
#endif
