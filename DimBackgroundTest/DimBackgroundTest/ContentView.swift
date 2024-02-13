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
		VStack(spacing: 36) {
			Button("Drawer 1") { openDrawer = .one }
			Button("Drawer 2") { openDrawer = .two }
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.teal)
		.dimBackground($dimBackground)
		.sheet(item: $openDrawer) { drawer in
			Group {
				switch drawer {
				case .one: DrawerOne()
				case .two: DrawerTwo()
				}
			}
			.onUIKitLifeCycleEvent(
				viewWillAppear: {
					withAnimation { dimBackground = true }
				},
				viewWillDisappear: {
					withAnimation { dimBackground = false }
				}
			)
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

extension View {
	typealias UIKitLifeCycleCallback = () -> Void

	func onUIKitLifeCycleEvent(
		viewWillAppear: UIKitLifeCycleCallback? = nil,
		viewWillDisappear: UIKitLifeCycleCallback? = nil
	) -> some View {
		modifier(UIKitLifeCycleModifier(
			onViewWillAppear: viewWillAppear,
			onViewWillDisappear: viewWillDisappear
		))
	}
}

private struct UIKitLifeCycleModifier: ViewModifier {
	var onViewWillAppear: View.UIKitLifeCycleCallback?
	var onViewWillDisappear: View.UIKitLifeCycleCallback?

	func body(content: Content) -> some View {
		content.background(UIViewControllerObserver(
			onViewWillAppear: onViewWillAppear,
			onViewWillDisappear: onViewWillDisappear
		))
	}
}

private struct UIViewControllerObserver: UIViewControllerRepresentable {
	typealias UIViewControllerType = UIViewController

	var onViewWillAppear: View.UIKitLifeCycleCallback?
	var onViewWillDisappear: View.UIKitLifeCycleCallback?

	func makeUIViewController(context: UIViewControllerRepresentableContext<UIViewControllerObserver>) -> UIViewControllerType {
		context.coordinator
	}

	func updateUIViewController(
		_: UIViewControllerType,
		context _: UIViewControllerRepresentableContext<UIViewControllerObserver>
	) { }

	func makeCoordinator() -> UIViewControllerObserverCoordinator {
		UIViewControllerObserverCoordinator(onViewWillAppear: onViewWillAppear, onViewWillDisappear: onViewWillDisappear)
	}

	class UIViewControllerObserverCoordinator: UIViewController {
		let onViewWillAppear: View.UIKitLifeCycleCallback?
		let onViewWillDisappear: View.UIKitLifeCycleCallback?

		init(onViewWillAppear: View.UIKitLifeCycleCallback? = nil, onViewWillDisappear: View.UIKitLifeCycleCallback? = nil) {
			self.onViewWillAppear = onViewWillAppear
			self.onViewWillDisappear = onViewWillDisappear
			super.init(nibName: nil, bundle: nil)
		}

		required init?(coder _: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override func viewWillAppear(_ animated: Bool) {
			super.viewWillAppear(animated)
			onViewWillAppear?()
		}

		override func viewWillDisappear(_ animated: Bool) {
			super.viewWillDisappear(animated)
			onViewWillDisappear?()
		}
	}
}
