import SwiftUI

/*
* A helper class to coordinate multiple views loading data from the API
*/
class ViewManager {

    // Properties
    private var viewsToLoad: Int
    private var loadedCount: Int
    private var hasErrors: Bool
    private var loginRequired: Bool

    // Callbacks to the AppView
    private var onLoadStateChanged: ((Bool) -> Void)?
    private var onLoginRequired: (() -> Void)?

    /*
     * Default to loading a single view, unless the parent informs us otherwise
     */
    init () {
        self.viewsToLoad = 1
        self.loadedCount = 0
        self.hasErrors = false
        self.loginRequired = false
    }

    /*
     * Work around Swift not allowing us to pass these parameters to the init method
     */
    func initialise(
        onLoadStateChanged: @escaping (Bool) -> Void,
        onLoginRequired: @escaping () -> Void) {

        self.onLoadStateChanged = onLoadStateChanged
        self.onLoginRequired = onLoginRequired
    }

    /*
     * Allow the parent to set the number of views to load
     */
    func setViewCount(count: Int) {
        self.reset()
        self.viewsToLoad = count
    }

    /*
     * Handle the view loading event and inform the parent, which can render a loading state
     */
    func onViewLoading() {
        self.onLoadStateChanged!(false)
    }

    /*
     * Handle the view loaded event and call back the parent when all loading is complete
     */
    func onViewLoaded() {

        self.loadedCount +=  1

        // Once all views have loaded, inform the parent if all views loaded successfully
        if self.loadedCount == self.viewsToLoad {

            if !self.hasErrors {
                self.onLoadStateChanged!(true)
            }

            self.reset()
        }
    }

    /*
     * Handle the view load failed event
     */
    func onViewLoadFailed(error: UIError) {

        self.loadedCount +=  1
        self.hasErrors = true

        // Record if this was a login required error
        if error.errorCode == ErrorCodes.loginRequired {
            self.loginRequired = true
        }

        // Once all views have loaded, reset state and, if required, trigger a login redirect only once
        if self.loadedCount == self.viewsToLoad {

            let triggerLoginOnParent = self.loginRequired
            self.reset()

            if triggerLoginOnParent {
                self.onLoginRequired!()
            }
        }
    }

    /*
     * Reset to the initial state once loading is complete
     * Default to loading a single view, unless the parent informs us otherwise
     */
    private func reset() {
        self.viewsToLoad = 1
        self.loadedCount = 0
        self.hasErrors = false
        self.loginRequired = false
    }
}
