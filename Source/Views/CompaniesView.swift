import SwiftUI
import SwiftCoroutine

/*
* The home view to show a list of companies
*/
struct CompaniesView: View {

    // External objects
    @ObservedObject var viewRouter: ViewRouter
    @EnvironmentObject var orientationHandler: OrientationHandler
    @EnvironmentObject var dataReloadHandler: DataReloadHandler

    // Properties
    private let viewManager: ViewManager
    private let apiClient: ApiClient

    // This view's state
    @State private var companies = [Company]()
    @State private var error: UIError?

    /*
     * Initialise from input
     */
    init (viewRouter: ViewRouter, viewManager: ViewManager, apiClient: ApiClient) {

        self.viewRouter = viewRouter
        self.viewManager = viewManager
        self.apiClient = apiClient
    }

    /*
     * Render the body and handle click events
     */
    var body: some View {

        let deviceWidth = UIScreen.main.bounds.size.width
        return VStack {

            // Show the header
            Text("Company List")
                .font(.headline)
                .frame(width: deviceWidth)
                .padding()
                .background(Colors.lightBlue)

            // Render errors getting data if required
            if self.error != nil {
                ErrorSummaryView(
                    hyperlinkText: "Problem Encountered in Companies View",
                    dialogTitle: "Companies View Error",
                    error: self.error!)
                        .padding(.top)
            }

            // Render the companies list if we can retrieve it
            if companies.count > 0 {

                List(companies, id: \.id) { item in

                    VStack {

                        HStack {
                            Image(String(item.id))
                                .frame(width: deviceWidth / 3, height: 0, alignment: .leading)
                                .padding(.leading, deviceWidth / 12)

                            Text(item.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(width: deviceWidth / 3, alignment: .leading)
                                .padding(.leading, deviceWidth / 12)

                        }.padding()

                        HStack {
                            Text("Target USD")
                                .labelStyle()
                                .frame(width: deviceWidth / 3, alignment: .leading)
                                .padding(.leading, deviceWidth / 12)

                            Text(self.formatAmount(value: item.targetUsd))
                                .valueStyle(textColor: Colors.paleGreen)
                                .frame(width: deviceWidth / 3, alignment: .leading)
                                .padding(.leading, deviceWidth / 12)

                        }.padding()

                        HStack {
                            Text("Investment USD")
                                .labelStyle()
                                .frame(width: deviceWidth / 3, alignment: .leading)
                                .padding(.leading, deviceWidth / 12)

                            Text(self.formatAmount(value: item.investmentUsd))
                                .valueStyle(textColor: Colors.paleGreen)
                                .frame(width: deviceWidth / 3, alignment: .leading)
                                .padding(.leading, deviceWidth / 12)

                        }.padding()

                        HStack {
                            Text("# Investors")
                                .labelStyle()
                                .frame(width: deviceWidth / 3, alignment: .leading)
                                .padding(.leading, deviceWidth / 12)

                            Text(String(item.noInvestors))
                                .valueStyle()
                                .frame(width: deviceWidth / 3, alignment: .leading)
                                .padding(.leading, deviceWidth / 12)

                        }.padding()

                    }.contentShape(Rectangle())
                     .onTapGesture {
                        self.moveToTransactions(id: item.id)
                    }
                }
            }

        }
        .onAppear(perform: self.initialLoad)
        .onReceive(self.dataReloadHandler.objectWillChange, perform: {causeError in
            self.loadData(causeError: causeError)
        })
    }

    /*
     * When a company is clicked, move to the transactions view and indicate which item
     */
    private func moveToTransactions(id: Int) {

        self.viewRouter.changeMainView(
            newViewType: TransactionsView.Type.self,
            newViewParams: [String(id)])
    }

    /*
     * Do the initial load
     */
    private func initialLoad() {
        self.loadData(causeError: false)
    }

    /*
     * Call the API to get data
     */
    private func loadData(causeError: Bool) {

        // Run async operations in a coroutine
        DispatchQueue.main.startCoroutine {

            do {
                // Initialise for this request
                self.error = nil
                let options = ApiRequestOptions(causeError: causeError)

                // Make the API call on a background thread
                self.viewManager.onViewLoading()
                try DispatchQueue.global().await {
                    self.companies = try self.apiClient.getCompanies(options: options).await()
                }
                self.viewManager.onViewLoaded()

            } catch {

                // Report errors
                let uiError = ErrorHandler.fromException(error: error)
                self.companies = [Company]()
                self.error = uiError
                self.viewManager.onViewLoadFailed(error: uiError)
            }
        }
    }

    /*
     * Format an amount field to include thousands separators
     */
    private func formatAmount(value: Int) -> String {
        return String(format: "%.0f", locale: Locale.current, Double(value))
    }
}
