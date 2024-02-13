//
//  ContentView.swift
//  DimBackgroundTest
//
//  Created by Suhayl Ahmed on 13/02/2024.
//

import SwiftUI

struct ContentView: View {

	private enum Drawer: Identifiable {
		var id: Self { self }
		case one
		case two
	}

	@State private var openDrawer: Drawer?
	@State private var dimBackground = false

	var body: some View {
		VStack {
			Button("Drawer 1") { withAnimation { dimBackground = true }; openDrawer = .one }
			Button("Drawer 2") { withAnimation { dimBackground = true }; openDrawer = .two }
		}
		.background(Color.teal)
		.dimBackground($dimBackground)
		.sheet(item: $openDrawer, onDismiss: { withAnimation { dimBackground = false } }) { drawer in
			Group {
				switch drawer {
				case .one: DrawerOne()
				case .two: DrawerTwo()
				}
			}
			.presentationDetents([.medium])
		}
	}

}

struct DrawerOne: View {
	var body: some View {
		Text("Hello world")
	}
}

struct DrawerTwo: View {
	var body: some View {
		Text("Goodbye world")
	}
}

struct DimBackground: ViewModifier {
	@Binding var shouldDimBackground: Bool

	func body(content: Content) -> some View {
		content
			.overlay {
				if shouldDimBackground {
					Color.black.opacity(0.5)
				}
			}
			.ignoresSafeArea()
	}
}

extension View {
	func dimBackground(_ shouldDimBackground: Binding<Bool>) -> some View {
		modifier(DimBackground(shouldDimBackground: shouldDimBackground))
	}
}
