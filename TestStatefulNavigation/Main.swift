//
//  TestStatefulNavigationApp.swift
//  TestStatefulNavigation
//
//  Created by Simon Wilson on 5/1/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct TestStatefulNavigationApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

public struct NavigationApp: ReducerProtocol {
	public struct State: Equatable {
		
		public var database: Database.State {
			get {
				Database.State(selection: selectedObject)
			}
			set {
				self.selectedObject = newValue.selection
			}
		}
		
		
		// Stateful navigation!
		public var selectedObject: URL?
	}
	
	public enum Action: Equatable {
		case navigateTo(URL?)
		
		case database(Database.Action)
	}
	
	public init() {}
	
	public var body: some ReducerProtocol<State,Action> {
		Reduce {state, action in
			switch action {
			case let .navigateTo(url):
				print("Navigating to \(url?.absoluteString ?? "<no url>")")
				return .none
				
			case .database(.sidebar(.selectionChanged(let url))):
				state.selectedObject = url
				return .none
				
				
				
//			case let .database(.sidebar(.binding(binding))):
//				print("App.binding: \(binding)")
//				return .none
			@unknown default:
//				print("NavigationApp: unknown action \(action)")
				return .none
				
			}
		}._printChanges()
		Scope(state: \.database, action: /NavigationApp.Action.database) {
			Database()
		}._printChanges()
	}
}

public struct RootView: View {
	// Setup the default store:
	let store: StoreOf<NavigationApp> = Store(initialState: NavigationApp.State.init(),
											  reducer: NavigationApp())
	
	public var body: some View {
		DatabaseView(store: self.store.scope(state: \.database,
											 action: NavigationApp.Action.database))
	}
	
	
}
