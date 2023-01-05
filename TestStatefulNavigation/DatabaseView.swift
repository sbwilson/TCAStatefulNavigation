//
//  ContentView.swift
//  TestStatefulNavigation
//
//  Created by Simon Wilson on 5/1/2023.
//

import SwiftUI
import ComposableArchitecture

struct DatabaseView: View {

	let store: StoreOf<Database>
	
	public init(store: StoreOf<Database>) {
		self.store = store
	}
	
	var body: some View {
		WithViewStore( self.store, observe: {$0}) { viewStore in
			NavigationSplitView(columnVisibility: .constant(.all)) {
				NavigationStack {
					DatabaseSidebarView(store: self.store.scope(state: \.sidebar,
																action: Database.Action.sidebar))
				}
				.navigationDestination(for: DatabaseSidebarItem.self) { item in
					Text("Item: \(item.id)")
				}
			} content: {
				Text("List")
			} detail: {
				VStack {
					Text("Detail")
					Button("Return home") {
						viewStore.send(.selectionChanged(nil))
					}
					Button("Select Capture") {
						viewStore.send(.selectionChanged(URL(string: "app://database/input/cafe")))
					}
					Button("Select Epic") {
						viewStore.send(.selectionChanged(URL(string: "app://database/beef")))
					}
					Button("Select Research") {
						viewStore.send(.selectionChanged(URL(string: "app://database/b00b")))
					}
				}
			}
		}
	}
}




public struct Database: ReducerProtocol {
	public struct State: Equatable {
		var selection: URL? = nil
		var sidebar: DatabaseSidebar.State {
			get {
				DatabaseSidebar.State(selection: selection)
			}
			set {
				self.selection = newValue.selection
			}
		}
		
	}
	public enum Action: Equatable {
		case sidebar(DatabaseSidebar.Action)
		case selectionChanged(URL?)
	}
	public init() {}
	
	public var body: some ReducerProtocol<State,Action> {
		Reduce { state, action in
			switch action {
//			case .sidebar(.binding(\.$selection)):
//				print("Database: sidebar.binding: \(state.sidebar.selection)")
//				return .none
//			case .sidebar(.selectionChanged(let url)):
//				print("New selection: \(url?.absoluteString ?? "<none>")")
//				return .none
			case let .selectionChanged(url):
				state.selection = url
				return .none
			default:
				return .none
			}
		}._printChanges()
		
		Scope(state: \.sidebar, action: /Action.sidebar) {
			DatabaseSidebar()
		}
	}
}



// MARK: - Sidebar

public struct DatabaseSidebarItem: Identifiable, Equatable, Hashable {
	public var id: URL
	public var name: String
	public var iconName: String
	
	public init(id: URL, name: String, iconName: String) {
		self.id = id
		self.name = name
		self.iconName = iconName
	}
}

public struct DatabaseSidebarView: View {
	
	let store: StoreOf<DatabaseSidebar>
//	@State private var selection: URL?
	
	public var body: some View {
		WithViewStore(self.store, observe: {$0}) { viewStore in
			
			List(selection: viewStore.binding(\.$selection)) {
				Section("Groups") {
					ForEach(viewStore.items) { item in
						NavigationLink(value: item) {
							HStack {
								Image(systemName: item.iconName)
								Text(item.name)
							}
						}
					}
				}
				Section("Inputs") {
					ForEach(viewStore.inputs) { item in
						NavigationLink(value: item) {
							HStack {
								Image(systemName: item.iconName)
								Text(item.name)
							}
						}
					}
				}
				
			}

		}
	}
	
}

public struct DatabaseSidebar: ReducerProtocol {
	public struct State: Equatable {
		@BindableState var selection: URL?
		
		
		public var items: [DatabaseSidebarItem] = [
			DatabaseSidebarItem(id: URL(string: "app://database/dead")!, name: "Local", iconName: "mappin.square"),
			DatabaseSidebarItem(id: URL(string: "app://database/beef")!, name: "Epic", iconName: "mappin.circle.fill"),
			DatabaseSidebarItem(id: URL(string: "app://database/b00b")!, name: "Research", iconName: "clipboard"),
		]
		
		public var inputs: [DatabaseSidebarItem] = [
			DatabaseSidebarItem(id: URL(string: "app://database/input/cafe")!, name: "Capture", iconName: "video"),
			DatabaseSidebarItem(id: URL(string: "app://database/input/face")!, name: "DVD", iconName: "opticaldisc"),
		]
	}
	public enum Action: Equatable, BindableAction {
		case buttonAction
		case selectionChanged(URL?)
		case binding(BindingAction<State>)
	}
	
	public init() {}
	
	public var body: some ReducerProtocol<State,Action> {
		CombineReducers {
			BindingReducer()
			Reduce {state, action in
				switch action {
				case .buttonAction:
					print("Sidebar: button clicked")
					return .none
				case .binding(\.$selection):
					print("Sidebar.Binding! \(state.selection?.absoluteString ?? "<none>")")
					return .none
				case .selectionChanged(_):
					return .none
				default:
					return .none
				}
			}
		}._printChanges()
		
	}
}


// MARK: - Search view
