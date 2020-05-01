import SwiftUI

/*
 * The current view renders based on the router location
 */
struct CurrentRouterView: View {

    // Properties
    private let viewManager: ViewManager?
    private let apiClient: ApiClient

    // The router
    @ObservedObject var viewRouter: ViewRouter

    /*
     * Receive properties from input
     */
    init (
        viewRouter: ViewRouter,
        viewManager: ViewManager,
        apiClient: ApiClient) {

        self.viewRouter = viewRouter
        self.viewManager = viewManager
        self.apiClient = apiClient
    }

    /*
     * Return the current view's markup, which depends on where we have navigated to
     */
    var body: some View {

        VStack {

            if self.viewRouter.currentViewType == TransactionsView.Type.self {

                // Render the transactions view
                TransactionsView(
                    viewRouter: viewRouter,
                    viewManager: viewManager!,
                    apiClient: self.apiClient)

            } else if self.viewRouter.currentViewType == LoginRequiredView.Type.self {

                // Render the login required view
                LoginRequiredView()

            } else {

                // Render the companies view by default
                CompaniesView(
                    viewRouter: viewRouter,
                    viewManager: viewManager!,
                    apiClient: self.apiClient)
            }
        }
    }
}
