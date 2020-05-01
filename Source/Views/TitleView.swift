import SwiftUI

/*
 * Represents the title row
 */
struct TitleView: View {

    // Properties supplied as input
    private let viewManager: ViewManager?
    private let apiClient: ApiClient?
    private var loadUserInfo = false

    // This view's state
    @State private var title = "OAuth 2.0 Demo App"

    /*
     * Called once 
     */
    init (viewManager: ViewManager?, apiClient: ApiClient?, loadUserInfo: Bool) {
        self.viewManager = viewManager
        self.apiClient = apiClient
        self.loadUserInfo = loadUserInfo
    }

    /*
     * Render the view
     */
    var body: some View {

        HStack {

            // Show the title aligned left
            Text(self.title)
                .fontWeight(.bold)
                .padding(20)
                .font(.system(size: 16))
                .frame(width: UIScreen.main.bounds.size.width * 0.55, alignment: .leading)

            // Render user info aligned right if the view should load
            if self.loadUserInfo {

                UserInfoView(
                    viewManager: self.viewManager,
                    apiClient: self.apiClient,
                    shouldLoadData: self.loadUserInfo)
                    .padding(20)
                    .frame(width: UIScreen.main.bounds.size.width  * 0.45, alignment: .trailing)
            }
        }
    }
}
