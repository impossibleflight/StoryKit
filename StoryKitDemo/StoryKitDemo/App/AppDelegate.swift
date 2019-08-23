//
//  AppDelegate.swift
//  StoryKitDemo
//
//  Created by John Clayton on 8/15/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import StoryKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		return true
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

		StoryKit.register(storyboards: Login.self, Main.self, Photos.self, Search.self, Favorites.self, Scripts.self, Tags.self)

		let stage: Stage
		do {
			stage = try Stage(window: self.window!)
		} catch {
			fatalError("Failed to initialize stage! \(error)")
		}
		Container.instance.stage = stage

		if let tabbarController = window?.rootViewController as? UITabBarController {
			tabbarController.delegate = self
		}

		// register some scripts that can match incoming URLs etc
		registerScripts()

		if let url = launchOptions?[.url] as? URL {
			Container.instance.stage.perform(url: url)
		}
		// select the last-selected tab by default
		else if let lastTab = Container.instance.lastTab {
			stage.select(lastTab).present(Login.login, unlessConditionMet: Container.instance.state.session).perform(animated: false)
		} else {
			stage.present(Login.login, unlessConditionMet: Container.instance.state.session).perform(animated: false)
		}

		return true
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		let sendingAppID = options[.sourceApplication]
		print("source application = \(sendingAppID ?? "Unknown")")

		Container.instance.stage.perform(url: url)
		return true
	}

	private func registerScripts() {
		let identifierPattern = "[\\w|-]+"

		// /categories
		stage.register { script in
			script.name = "Categories"
			script.root(Main.root)
				.select(Main.categories)
		}

		// /categories/<name>
		stage.register { script in
			script.name = "Category photos"
			script.root(Main.root)
				.select(Main.categories)
				.set(Photos.categories)
				.push(Photos.photosForCategory, capture: identifierPattern, label: "category")
		}

		// /categories/<name>/photos/<identifier>
		stage.register { script in
			script.name = "Photo for category"
			script.root(Main.root)
				.select(Main.categories)
				.set(Photos.categories)
				.push(Photos.photosForCategory, capture: identifierPattern, label: "category")
				.prop("photos")
				.push(Photos.photo, capture: identifierPattern, label: "photo")
		}

		// /search
		stage.register { script in
			script.name = "Search"
			script.root(Main.root)
				.select(Main.search)
		}

		// /search/<query>
		stage.register { script in
			script.name = "Search results"
			script.root(Main.root)
				.select(Main.search)
				.set(Search.search)
				.push(Search.results, capture: "\\w+", label: "query")
		}

		// /favorites
		stage.register { script in
			script.name = "Favorites"
			script.root(Main.root)
				.select(Main.favorites)
		}

		// /favorites/<favoriteID>
		stage.register { script in
			script.name = "Favorite photo"
			script.root(Main.root)
				.select(Main.favorites)
				.set(Favorites.favorites)
				.push(Favorites.favorite, capture: "\\d+", label: "favorite", transform: { Int($0)! })
		}
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

extension AppDelegate: UITabBarControllerDelegate {
	public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		Container.instance.lastTab = viewController.sceneDescriptor
	}

}
