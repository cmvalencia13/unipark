import Foundation

public struct NetworkInterceptor {
	public init() {}

	/// Adds common headers for JSON APIs.
	public func intercept(request: inout URLRequest) {
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
	}
}