@testable import LurewakeAPI

import Foundation
import Testing

@Suite("Lure Inventory Response Tests")
struct LureInventoryResponseTests {

    @Test("Empty inventory response encodes correctly")
    func emptyInventoryResponse() throws {
        let response = LureInventoryResponse(
            items: [],
            returnedCount: 0,
            limit: 100
        )

        let encoded = try JSONEncoder().encode(response)

        let decoded = try JSONDecoder().decode(
            LureInventoryResponse.self,
            from: encoded
        )

        #expect(decoded.items.isEmpty)
        #expect(decoded.returnedCount == 0)
        #expect(decoded.limit == 100)
    }
}
