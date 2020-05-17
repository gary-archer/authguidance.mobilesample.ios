import Foundation
import SwiftCoroutine

/*
 * Data and non UI logic for the transactions view
 */
class TransactionsViewModel: ObservableObject {

    // Properties
    private let viewManager: ViewManager
    private let apiClient: ApiClient

    // Published state
    @Published var companyId: String = ""
    @Published var data: CompanyTransactions?
    @Published var error: UIError?

    /*
     * Initialise from input
     */
    init (viewManager: ViewManager, apiClient: ApiClient) {
        self.viewManager = viewManager
        self.apiClient = apiClient
    }

    /*
     * Do the work of calling the API
     */
    func callApi(
        options: ApiRequestOptions,
        onError: @escaping (Bool) -> Void) {

        // Run async operations in a coroutine
        DispatchQueue.main.startCoroutine {

            do {

                // Initialise for this request
                self.error = nil
                self.viewManager.onViewLoading()
                var data: CompanyTransactions?

                // Make the API call on a background thread
                try DispatchQueue.global().await {
                    data = try self.apiClient.getCompanyTransactions(companyId: self.companyId, options: options)
                        .await()
                }

                // Update published properties on the main thread
                self.data = data
                self.viewManager.onViewLoaded()

            } catch {

                // Handle the error
                self.data = nil

                // If this is a real error we update error state
                let uiError = ErrorHandler.fromException(error: error)
                let isExpected = self.handleApiError(error: uiError)
                if !isExpected {
                    self.error = uiError
                    self.viewManager.onViewLoadFailed(error: uiError)
                }

                // Inform the view
                onError(isExpected)
            }
        }
    }

    /*
     * Handle 'business errors' received from the API
     */
    private func handleApiError(error: UIError) -> Bool {

        var isExpected = false

        if error.statusCode == 404 && error.errorCode == ErrorCodes.companyNotFound {

            // A deep link could provide an id such as 3, which is unauthorized
            isExpected = true

        } else if error.statusCode == 400 && error.errorCode == ErrorCodes.invalidCompanyId {

            // A deep link could provide an invalid id value such as 'abc'
            isExpected = true
        }

        return isExpected
    }
}
